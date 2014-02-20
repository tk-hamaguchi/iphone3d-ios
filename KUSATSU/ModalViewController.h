//
//  ModalViewController.h
//  KUSATSU
//
//  Created by TatsuyaEgawa on 2014/02/20.
//  Copyright (c) 2014年 fisproject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalViewController : UIViewController

-(IBAction)closeKeyboard:(id)sender;

@property (nonatomic, retain)IBOutlet UITextField *inputID;
@property (nonatomic, retain)IBOutlet UITextField *inputPASS;

@end
