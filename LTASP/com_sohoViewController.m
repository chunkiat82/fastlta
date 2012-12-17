//
//  com_sohoViewController.m
//  LTASP
//
//  Created by Ho, Raymond on 17/12/12.
//  Copyright (c) 2012 Ho, Raymond. All rights reserved.
//

#import "com_sohoViewController.h"

@interface com_sohoViewController ()

@end

@implementation com_sohoViewController

@synthesize goButton;
@synthesize outputText;
@synthesize inputText;
@synthesize inputLabel;
@synthesize icLabel;
@synthesize responseView;
@synthesize dateLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [goButton addTarget:self action:@selector(doGoButton) forControlEvents:UIControlEventTouchUpInside];
        // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) doGoButton
{
	//window.backgroundColor = [UIColor redColor];
    NSLog(@"INPUT STRING %@",inputText.text);
    inputLabel.text=@"";
    NSString *string = [inputText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSError *error = NULL;
    NSRegularExpression *numberPlateRegex = [NSRegularExpression regularExpressionWithPattern:@"[Ss]*[A-Za-z][A-Za-z][0-9][0-9][0-9][0-9][A-Za-z][dD]*" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *icRegex = [NSRegularExpression regularExpressionWithPattern:@"[SsGg][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Za-z]" options:NSRegularExpressionCaseInsensitive error:&error];
    
    //NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
    //NSLog(@"%@", modifiedString);
    NSRange numberPlate = [numberPlateRegex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])];

    if (!NSEqualRanges(numberPlate, NSMakeRange(NSNotFound, 0))) {

        NSString *substringForFirstMatch = [string substringWithRange:numberPlate];
        inputLabel.text=[substringForFirstMatch uppercaseString];
        NSLog(@"%@", substringForFirstMatch);

    }
    
    NSRange icNumber = [icRegex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    if (!NSEqualRanges(icNumber, NSMakeRange(NSNotFound, 0))) {

        NSString *substringForFirstMatch = [string substringWithRange:icNumber];
        icLabel.text=[substringForFirstMatch uppercaseString];
        NSLog(@"%@", substringForFirstMatch);

    }
    NSDate *now = [NSDate date];
	NSDateComponents *dc = [[NSDateComponents alloc] init];
	[dc setMonth:1];
	NSDate *MyTargetDateObject = [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:now options:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"ddMMyyyy"];
    dateLabel.text = [dateFormatter stringFromDate:MyTargetDateObject];
    NSLog(@"%@",dateLabel.text);


//    NSString *post = @"dispatch=sendWithOutPaymentDetails&exportStatus=Yes&intendedDeRegDate=31122012&ownerIdType=1&ownerId=%@&vehicleNo=%@",icLabel.text,inputLabel.text) ;
    NSString *post = [NSString stringWithFormat:@"dispatch=sendWithOutPaymentDetails&exportStatus=Yes&intendedDeRegDate=%@&ownerIdType=1&ownerId=%@&vehicleNo=%@",dateLabel.text,icLabel.text,inputLabel.text];
    
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://vrl.lta.gov.sg/lta/vrl/action/enquireRebateByPublicBeforeDeregInput?FUNCTION_ID=F0304009TT"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
    NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
    //NSLog(@"responseData: %@", content);
    
    NSString *stripped = [[content componentsSeparatedByString:@"<table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\">"] lastObject];
   // [outputText setText:stripped];
    [responseView loadHTMLString:stripped baseURL:nil];
    [self.view endEditing:YES];
    NSLog(@"DONE");
}
@end
