//
//  ViewController.h
//  KUSATSU
//
//  Created by T.Egawa on 2014/02/07.
//  Copyright (c) 2014年 fisproject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewController.h"
#import "WebViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"

#define FRAMERATE 10

@interface ViewController : UIViewController{
    NSMutableArray *imageList;
}

@property (nonatomic, retain)UIImage *srcImage;
@property (nonatomic, retain)UIImageView *imageView;
@property (nonatomic, retain)NSString *getURL;
@property (nonatomic, retain)NSDictionary *userInfo;
@property int captureCount;
@property BOOL isEnableSend;
@end
