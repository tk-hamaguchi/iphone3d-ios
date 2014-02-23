//
//  WebViewController.h
//  KUSATSU
//
//  Created by TatsuyaEgawa on 2014/02/23.
//  Copyright (c) 2014年 fisproject. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DOCOMO_URL @"https://api.smt.docomo.ne.jp/api/login?client_id=000000000089&display=smartphone&redirect_uri=http%3A%2F%2Fiphone3d.now.tl%2Fusers%2Fauth%2Fdocomo_cloud%2Fcallback&response_type=code&state=f1caf3d0f9c860e7c9876f94209e7615eb5065a40c963c51"

@interface WebViewController : UIViewController

@property (nonatomic, retain) UIWebView *webView;

@end
