//
//  MasterViewController.m
//  LTA Fast
//
//  Created by Raymond Ho on 21/12/12.
//  Copyright (c) 2012 Raymond Ho. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [self loadDefaults];
    [super awakeFromNib];
}

- (void)loadDefaults
{
   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *historyList = [defaults objectForKey:@"historyList"];

    // load the data
    if (historyList){
        NSLog(@"load loadDefaults");
        for (NSString *object in [historyList reverseObjectEnumerator]) {
            NSLog(@"String %@",object);
            [self addToHistory:object];
        }
    }

    //need to create function to take in parameter and add to the list
    
}

- (void) addToDB:(NSString *)input
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *historyList = [defaults objectForKey:@"historyList"];

    if (!historyList){
        historyList =  [[NSMutableArray alloc] init];
        NSLog(@"Initializing Array");
    }else{
        historyList =  [[NSMutableArray alloc] initWithArray:historyList];
    }
    NSLog(@"AddToDB %@",input);

    [historyList insertObject:input atIndex:0];
    [defaults setObject:historyList forKey:@"historyList"];
    [defaults synchronize];
    
    [self addToHistory:input];

}
- (void) addToHistory:(NSString *)input{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:input atIndex:0];    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)removeObjectAtIndex:(NSUInteger)index{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *historyList = [defaults objectForKey:@"historyList"];
    NSString *temp = _objects[index];
    
    NSMutableArray *discardedItems = [NSMutableArray array];    
    historyList =  [[NSMutableArray alloc] initWithArray:historyList];
     if (historyList){
        for (NSString *item in historyList) {
            NSLog(@"String %@",item);
            if([item isEqual:temp]){
                [discardedItems addObject:item];
            }
        }
    }
    [historyList removeObjectsInArray:discardedItems];
    [defaults setObject:historyList forKey:@"historyList"];
    [defaults removeObjectForKey:temp];
    [defaults synchronize];
    [_objects removeObjectAtIndex:index];
}

- (NSString *) infoExtract:(NSString *)input{
    NSString *output =@"";

    NSString *icString = @"";
    NSString *cpString = @"";

    NSString *inputText= input;
    
    //disable whitespace removal
    NSString *string = [inputText stringByReplacingOccurrencesOfString:@"" withString:@""];

    NSError *error = NULL;
    NSRegularExpression *numberPlateRegex = [NSRegularExpression regularExpressionWithPattern:@"[SsEu][A-Za-z]{0,2}[0-9]{1,4}[A-Za-z][dD]*" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *icRegex = [NSRegularExpression regularExpressionWithPattern:@"[SsGg][0-9]{7}[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:&error];
    
    //NUMBER PLATE EXTRACTION
    NSRange numberPlate = [numberPlateRegex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    if (!NSEqualRanges(numberPlate, NSMakeRange(NSNotFound, 0))) {

        NSString *substringForFirstMatch = [string substringWithRange:numberPlate];
        cpString=[substringForFirstMatch uppercaseString];
        //NSLog(@"%@", substringForFirstMatch);

    }

    //IC EXTRACTION
    NSRange icNumber = [icRegex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    if (!NSEqualRanges(icNumber, NSMakeRange(NSNotFound, 0))) {

        NSString *substringForFirstMatch = [string substringWithRange:icNumber];
        icString=[substringForFirstMatch uppercaseString];
        //NSLog(@"%@", substringForFirstMatch);

    }
    output = [output stringByAppendingString:icString];
    output = [output stringByAppendingString:@" "];
    output = [output stringByAppendingString:cpString];
    return output;
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1){
        NSLog(@"Alert View dismissed with button at index %d",buttonIndex);
        NSString *inputText = [alertView textFieldAtIndex:0].text;
        NSLog(@"Storing %@",inputText);
        NSLog(@"Extraction %@",[self infoExtract:inputText]);
        [self addToDB:[self infoExtract:inputText]];
        
    }
    else{
        //DO NOTHING
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
   

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"IC & CAR PLATE" message:@"Enter the message"
                                            delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
     
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];

    
   // NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
   // [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSString *object = _objects[indexPath.row];
    cell.textLabel.text = object;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //[_objects removeObjectAtIndex:indexPath.row];        
        [self removeObjectAtIndex:indexPath.row];
        //TODO: EDIT FROM HISTORY
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
