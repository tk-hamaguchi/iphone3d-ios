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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cat.jpg"]];
    CGRect rect = CGRectMake(5,55, 560, 210);
    self.imageView.frame = rect;
    [self.view addSubview:self.imageView];
    
    UIImage *src = [UIImage imageNamed:@"cat.jpg"];
    [self imageRender:src];
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

#pragma mark HTTP

-(void)getImageFromCamera{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:@"http://localhost/test.json"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // 通信に成功した場合の処理
             NSLog(@"responseObject: %@", responseObject);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // エラーの場合はエラーの内容をコンソールに出力する
             NSLog(@"Error: %@", error);
         }];
}

-(void)postImageData{
    // File Upload with Progress Callback
//    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"avatar.jpg"], 0.5);
//    NSMutableURLRequest *request = [[AFHTTPClient sharedClient]
//                                    multipartFormRequestWithMethod:@"POST" path:@"/upload"
//                                    parameters:nil constructingBodyWithBlock: ^(id formData) {
//                                        [formData appendPartWithFileData:data mimeType:@"image/jpeg" name:@"avatar"];
//                                    }];
//    
//    AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc]
//                                          initWithRequest:request] autorelease];
//    [operation setUploadProgressBlock:
//     ^(NSUInteger totalBytesWritten, NSUInteger totalBytesExpectedToWrite) {
//         NSLog(@"Sent %d of %d bytes", totalBytesWritten, totalBytesExpectedToWrite);
//     }];
//    
//    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
//    [queue addOperation:operation];
}

#pragma mark Image Processing

/**
 *
 * VGA 640*480 * 2枚 = 1280 * 480 -> (* 0.875) 560 * 210
*/

-(void)imageRender:(UIImage*)src{
    
    CGFloat srcWidth = CGImageGetWidth(src.CGImage);
    CGFloat srcHeight = CGImageGetHeight(src.CGImage);
    NSLog(@"%f:%f",srcWidth,srcHeight);
    
    //画像サイズ
    UIGraphicsBeginImageContext(CGSizeMake(560, 210));
    
    // トリミング origin.x  origin.y w h
    float move = 50.0;
    CGRect leftRect = CGRectMake(move, 0.0, srcWidth, srcHeight);
    CGRect rightRect = CGRectMake(-move, 0.0, srcWidth, srcHeight);
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
