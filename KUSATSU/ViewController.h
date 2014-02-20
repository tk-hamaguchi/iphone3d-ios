//
//  ViewController.h
//  KUSATSU
//
//  Created by T.Egawa on 2014/02/07.
//  Copyright (c) 2014年 fisproject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"

@interface ViewController : UIViewController

@property (nonatomic, retain)UIImage *srcImage;
@property (nonatomic, retain)UIImageView *imageView;
@property (nonatomic, retain)NSString *getURL;
@property (nonatomic, retain)NSDictionary *userInfo;
@property int captureCount;
@end
