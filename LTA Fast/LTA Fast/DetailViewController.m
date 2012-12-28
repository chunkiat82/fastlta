//
//  DetailViewController.m
//  LTA Fast
//
//  Created by Raymond Ho on 21/12/12.
//  Copyright (c) 2012 Raymond Ho. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    if (self.detailItem) {
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *storeHtml = [defaults objectForKey:[self.detailItem description]];

        if (!storeHtml){
            // Update the user interface for the detail item.
            NSString *dateString = @"";
            NSString *icString = @"";
            NSString *cpString = @"";
            
            NSString *inputText= [self.detailItem description];
            
            //disable whitespace removal
            NSString *string = [inputText stringByReplacingOccurrencesOfString:@"" withString:@""];
            
            NSError *error = NULL;
            NSRegularExpression *numberPlateRegex = [NSRegularExpression regularExpressionWithPattern:@"[Ss]*[A-Za-z]{2}[0-9]{1,4}[A-Za-z][dD]*" options:NSRegularExpressionCaseInsensitive error:&error];
            NSRegularExpression *icRegex = [NSRegularExpression regularExpressionWithPattern:@"[SsGg][0-9]{7}[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:&error];
            
            //NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
            //NSLog(@"%@", modifiedString);
            NSRange numberPlate = [numberPlateRegex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])];

            if (!NSEqualRanges(numberPlate, NSMakeRange(NSNotFound, 0))) {

                NSString *substringForFirstMatch = [string substringWithRange:numberPlate];
                cpString=[substringForFirstMatch uppercaseString];
                NSLog(@"%@", substringForFirstMatch);

            }
            
            NSRange icNumber = [icRegex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
            if (!NSEqualRanges(icNumber, NSMakeRange(NSNotFound, 0))) {

                NSString *substringForFirstMatch = [string substringWithRange:icNumber];
                icString=[substringForFirstMatch uppercaseString];
                NSLog(@"%@", substringForFirstMatch);

            }
            NSDate *now = [NSDate date];
            NSDateComponents *dc = [[NSDateComponents alloc] init];
            [dc setMonth:1];
            NSDate *MyTargetDateObject = [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:now options:0];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"ddMMyyyy"];
            dateString = [dateFormatter stringFromDate:MyTargetDateObject];
            
            NSLog(@"%@",dateString);


        //    NSString *post = @"dispatch=sendWithOutPaymentDetails&exportStatus=Yes&intendedDeRegDate=31122012&ownerIdType=1&ownerId=%@&vehicleNo=%@",icLabel.text,inputLabel.text) ;
            NSString *post = [NSString stringWithFormat:@"dispatch=sendWithOutPaymentDetails&exportStatus=Yes&intendedDeRegDate=%@&ownerIdType=1&ownerId=%@&vehicleNo=%@",dateString,icString,cpString];
            
            
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
            [self.detailWebView loadHTMLString:stripped baseURL:nil];
            [self.view endEditing:YES];
            NSLog(@"DONE");


            NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
            [dateFormatter1 setDateFormat:@"ddMMyyyy HH:mm"];
            dateString = [dateFormatter1 stringFromDate:MyTargetDateObject];
//            self.detailDescriptionLabel.text = [NSString stringWithFormat:@"%@ %@ %@",icString,cpString,dateString ];
            self.navItem.title = [self.detailItem description];
            [self withHtml:stripped withInput:inputText withInfo:[NSString stringWithFormat:@"%@ %@ %@",icString,cpString,dateString ]];
        }
        else{
            self.navItem.title = [self.detailItem description];
            [self.detailWebView loadHTMLString:storeHtml baseURL:nil];
        }

    }
}
- (void) withHtml:(NSString *)html withInput:(NSString *)input withInfo:(NSString *)info{
    NSLog(@"input=%@ info=%@",input,info);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSMutableArray *storeHtml = [defaults objectForKey:input];
    [defaults setObject:html forKey:input];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"History", @"History");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
