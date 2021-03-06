//
//  ViewController.m
//  KUSATSU
//
//  Created by T.Egawa on 2014/02/07.
//  Copyright (c) 2014年 fisproject. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(responseFromModalView:)
                   name:@"inputDone" object:nil];
    
    [center addObserver:self selector:@selector(responseFromWebView:)
                   name:@"webViewDone" object:nil];
    
    if (self.userInfo == NULL) {
        ModalViewController *modalViewController = [[ModalViewController alloc]
                                                    initWithNibName:@"ModalViewController" bundle:nil];
        modalViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        modalViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:modalViewController animated:YES completion:nil];
    }
}

-(void)responseFromModalView:(NSNotification*)nofify{
    self.userInfo = nofify.userInfo;
    [self getImageFromCamera];
}

-(void)responseFromWebView:(NSNotification*)nofify{
    self.isEnableSend = YES;
    [self getImageFromCamera];
}

- (void)viewDidLoad
{
    self.captureCount = 0;
    self.isEnableSend = YES;
    imageList = [NSMutableArray array];

    [super viewDidLoad];

#ifdef DEBUG_MODE
    self.getURL = @"http://192.168.2.1";
    self.imageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cat.jpg"]];
    CGRect rect = CGRectMake(5,55, 560, 210);
    self.imageView.frame = rect;
    [self.view addSubview:self.imageView];
    UIImage *src = [UIImage imageNamed:@"cat.jpg"];
    [self imageRender:src];
#else
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.getURL = [NSString stringWithFormat:@"http://%@", [userDefaults stringForKey:@"target_ip_preference"]];
    self.imageView =[[UIImageView alloc]initWithImage:NULL];
    CGRect rect = CGRectMake(5,55, 560, 210);
    self.imageView.frame = rect;
    [self.view addSubview:self.imageView];
#endif
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(IBAction)getCapture:(id)sender{
    [self getImageFromCamera];
}

-(IBAction)appearWebView:(id)sender{
    [imageList removeAllObjects];
    self.isEnableSend = NO;
    WebViewController *modalViewController = [[WebViewController alloc]
                                                initWithNibName:@"WebViewController" bundle:nil];
    modalViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    modalViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:modalViewController animated:YES completion:nil];
}

#pragma mark HTTP

-(void)getImageFromCamera{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    
    NSDictionary *params = @{@"action": @"snapshot"};
    
    [manager GET:self.getURL parameters:params
         success:^(NSURLSessionDataTask *task, UIImage *image) {
             [self imageRender:image];
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Error: %@", error);
             [self imageRender:NULL];
         }];
}

-(void)sendImageBinary:(int)frameRate{

    //NSLog(@"self.userInfo -> %@ ",self.userInfo.allKeys);
    int ticks_per_second = 100;

    NSDictionary *params = @{
                             @"docomo_id": [self.userInfo objectForKey:@"id"],
                             @"docomo_pass": [self.userInfo objectForKey:@"pass"],
                                   @"delay": [NSNumber numberWithInteger:( ticks_per_second / frameRate )]
                               };
  
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:@"http://iphone3d.now.tl/api/movies" parameters:params
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
        // send ImageData
        for (int i =0; i < [imageList count]; i++) {
            NSString *imgName = [NSString stringWithFormat:@"image_%d.jpg",i];
            [formData appendPartWithFileData:[imageList objectAtIndex:i]
                                        name:@"movie[images_attributes][][pic]"
                                    fileName:imgName
                                    mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        [imageList removeAllObjects];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@  (errorCode:%ld)", error, error.code);
    }];

}

#pragma mark Image Processing

/**
 *
 * VGA 640*480 * 2 = 1280 * 480 -> (* 0.875) 560 * 210
*/

-(void)imageRender:(UIImage*)src{
    NSLog(@"imageRender(%d)",self.captureCount);
    
    if(src == NULL)[self getImageFromCamera];
    
    CGFloat srcWidth = CGImageGetWidth(src.CGImage);
    CGFloat srcHeight = CGImageGetHeight(src.CGImage);
    //NSLog(@"%f:%f",srcWidth,srcHeight);
    
    //画像サイズ
    UIGraphicsBeginImageContext(CGSizeMake(560, 210));
    
    // トリミング origin.x  origin.y w h
    float shift = 50.0;
    CGRect leftRect = CGRectMake(shift, 0.0, srcWidth, srcHeight);
    CGRect rightRect = CGRectMake(0, 0.0, srcWidth - shift, srcHeight);
    CGImageRef cgImageLeft = CGImageCreateWithImageInRect(src.CGImage, leftRect);
    CGImageRef cgImageRight = CGImageCreateWithImageInRect(src.CGImage, rightRect);

    // resize
    UIImage *thumbnailImageLeft = [self resize:[UIImage imageWithCGImage:cgImageLeft]
                                    rect:CGRectMake(0, 0, 640, 480)];
    UIImage *thumbnailImageRight = [self resize:[UIImage imageWithCGImage:cgImageRight]
                                    rect:CGRectMake(0, 0, 640, 480)];

    //合成
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, 210);
    CGContextScaleCTM(ctx, 1, -1); // 上下反転対策
    CGContextDrawImage(ctx, CGRectMake(0, 0, 280, 210), thumbnailImageLeft.CGImage);
    CGContextDrawImage(ctx, CGRectMake(280, 0, 280, 210), thumbnailImageRight.CGImage);
    CGImageRef imgRef = CGBitmapContextCreateImage (ctx);
    UIImage *output = [UIImage imageWithCGImage:imgRef];
    
    self.imageView.image = output;
    [imageList addObject:UIImageJPEGRepresentation(output, 0.01)];
    
    usleep(1000000 / FRAMERATE); // 0.1sec
    
    [self checkCaptureCount];
}


-(UIImage *)resize:(UIImage *)image rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    UIGraphicsEndImageContext();
    return resizedImage;
}

-(void)checkCaptureCount{
    self.captureCount++;
    
    if (self.captureCount == (FRAMERATE * 3)) {
        if(self.isEnableSend)[self sendImageBinary:self.captureCount];
        self.captureCount=0;
    } else {
        [self getImageFromCamera];
    }
}

@end
