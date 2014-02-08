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

-(void)image{
    //オリジナル画像
    UIImage *src = self.srcImage;
    
    CGFloat srcWidth = CGImageGetWidth(src.CGImage);
    CGFloat srcHeight = CGImageGetHeight(src.CGImage);
    
    //画像合成
    UIGraphicsBeginImageContext(CGSizeMake(srcWidth * 2, srcHeight * 2));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [src drawInRect:CGRectMake(0, 0, srcWidth, srcHeight)];
    [src drawInRect:CGRectMake(srcWidth, 0, srcWidth, srcHeight)];
    [src drawInRect:CGRectMake(0, srcHeight, srcWidth, srcHeight)];
    [src drawInRect:CGRectMake(srcWidth, srcHeight, srcWidth, srcHeight)];
    
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSelectFont(ctx, "Helvetica", 15.0, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextShowTextAtPoint(ctx, 0, 0, "0,0", 3);
    CGContextShowTextAtPoint(ctx, 50, 0, "50,0", 4);
    CGContextShowTextAtPoint(ctx, 0, 50, "0,50", 4);
    CGContextShowTextAtPoint(ctx, 50, 50, "50,50", 5);
    
    // 合成
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGContextTranslateCTM(ctx, 0, srcHeight * 1.2); //文字の高さ分ずらした
}

@end
