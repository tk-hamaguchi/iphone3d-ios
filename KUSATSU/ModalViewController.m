//
//  ModalViewController.m
//  KUSATSU
//
//  Created by TatsuyaEgawa on 2014/02/20.
//  Copyright (c) 2014年 fisproject. All rights reserved.
//

#import "ModalViewController.h"

@interface ModalViewController ()

@end

@implementation ModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.inputID.text   = [userDefaults stringForKey:@"docomo_id_preference"];
    self.inputPASS.text = [userDefaults stringForKey:@"docomo_password_preference"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPush:(id)sender{
    NSString *_id = self.inputID.text;
    NSString *_pass = self.inputPASS.text;
    
    if ([_id length] == 0 || [_pass length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Confirm your UserID or Pass"
                                  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSDictionary *dic = @{@"id": _id,@"pass": _pass};
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_id forKey:@"docomo_id_preference"];
    [userDefaults setObject:_pass forKey:@"docomo_password_preference"];
    [userDefaults synchronize];
    
    NSNotification *notify = [NSNotification notificationWithName:@"inputDone" object:self userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
    
    // Close
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)closeKeyboard:(id)sender{
    [self.inputID resignFirstResponder];
    [self.inputPASS resignFirstResponder];
}

@end
