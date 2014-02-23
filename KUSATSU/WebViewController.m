//
//  WebViewController.m
//  KUSATSU
//
//  Created by TatsuyaEgawa on 2014/02/23.
//  Copyright (c) 2014年 fisproject. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.webView = [[UIWebView alloc] init];
        self.webView.frame = CGRectMake(0, 20, 568, 260);
        [self.view addSubview:self.webView];
    }
    return self;
}

- (void)viewDidLoad
{
    NSURL *url = [NSURL URLWithString:DOCOMO_URL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPush:(id)sender{
    NSNotification *notify = [NSNotification notificationWithName:@"webViewDone" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
    
    // Close
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
