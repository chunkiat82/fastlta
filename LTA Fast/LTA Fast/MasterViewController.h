//
//  MasterViewController.h
//  LTA Fast
//
//  Created by Raymond Ho on 21/12/12.
//  Copyright (c) 2012 Raymond Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
