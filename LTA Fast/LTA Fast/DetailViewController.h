//
//  DetailViewController.h
//  LTA Fast
//
//  Created by Raymond Ho on 21/12/12.
//  Copyright (c) 2012 Raymond Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
