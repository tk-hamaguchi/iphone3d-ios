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
    [center addObserver:self selector:@selector(response:)
                   name:@"inputDone" object:nil];
    
    if (self.userInfo == NULL) {
        ModalViewController *modalViewController = [[ModalViewController alloc]
                                                    initWithNibName:@"ModalViewController"
                                                    bundle:nil];
        modalViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        modalViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:modalViewController animated:YES completion:nil];
    }
}

-(void)response:(NSDictionary*)dic{
    NSLog(@"%@",dic);
    self.userInfo = dic;
}

- (void)viewDidLoad
{
    self.captureCount = 0;
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
    self.getURL = @"http://192.168.0.150";
    self.imageView =[[UIImageView alloc]initWithImage:NULL];
    CGRect rect = CGRectMake(5,55, 560, 210);
    self.imageView.frame = rect;
    [self.view addSubview:self.imageView];
#endif
	// Do any additional setup after loading the view, typically from a nib.
    
    [self getImageFromCamera];
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

#pragma mark HTTP

-(IBAction)get:(id)sender{
    [self getImageFromCamera];
}

-(void)getImageFromCamera{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    
    NSDictionary *params = @{@"action": @"snapshot"};
    
    [manager GET:self.getURL parameters:params
         success:^(NSURLSessionDataTask *task, UIImage *image) {
             // 通信に成功した場合の処理
             [self imageRender:image];
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Error: %@", error);
             [self imageRender:NULL];
         }];
}

-(void)postImageData:(UIImage*)input{
    
    NSData *imageData = UIImageJPEGRepresentation(input, 0.01);
    
    if (imageData==nil) return;
    
    NSDictionary *params = @{@"docomo_id": @"docomo_id",@"docomo_pass": @"docomo_pass",@"movie[images_attributes][][pic]":imageData,};
  
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:@"http://iphone3d.now.tl/api/movies" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // send ImageData
        //[formData appendPartWithFormData:imageData name:@"image"];
        [formData appendPartWithFileData:imageData name:@"movie[images_attributes][][pic]" fileName:@"image.jpg" mimeType:@"image/jpeg"];

         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@  (errorCode:%d)", error, error.code);
    }];
}

#pragma mark Image Processing

/**
 *
 * VGA 640*480 * 2枚 = 1280 * 480 -> (* 0.875) 560 * 210
*/

-(void)imageRender:(UIImage*)src{
    
    if(src == NULL)[self getImageFromCamera];
    
    CGFloat srcWidth = CGImageGetWidth(src.CGImage);
    CGFloat srcHeight = CGImageGetHeight(src.CGImage);
    //NSLog(@"%f:%f",srcWidth,srcHeight);
    
    //画像サイズ
    UIGraphicsBeginImageContext(CGSizeMake(560, 210));
    
    // トリミング origin.x  origin.y w h
    float move = 50.0;
    CGRect leftRect = CGRectMake(move, 0.0, srcWidth, srcHeight);
    CGRect rightRect = CGRectMake(0, 0.0, srcWidth-move, srcHeight);
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
    
    usleep(100000); // 0.1sec
    [self getImageFromCamera];
    
    if(self.captureCount % 10 == 0)[self postImageData:output];

    self.captureCount++;
    
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

@end
