//
//  com_sohoViewController.h
//  LTASP
//
//  Created by Ho, Raymond on 17/12/12.
//  Copyright (c) 2012 Ho, Raymond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface com_sohoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UITextView *outputText;
@property (weak, nonatomic) IBOutlet UITextField *inputText;
@property (weak, nonatomic) IBOutlet UILabel *inputLabel;
@property (weak, nonatomic) IBOutlet UILabel *icLabel;
@property (weak, nonatomic) IBOutlet UIWebView *responseView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
