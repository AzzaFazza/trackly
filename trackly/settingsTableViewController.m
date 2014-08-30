//
//  settingsTableViewController.m
//  Taskly
//
//  Created by Adam Fallon on 30/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import "settingsTableViewController.h"
#import <Parse/Parse.h>
#import "videoViewController.h"
#import "CoreDataHelper.h"

@interface settingsTableViewController () {
    NSArray * settings;
}

@end

@implementation settingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    settings = [NSArray arrayWithObjects:@"About", @"Attributions", @"Logout", @"Turn Off Voice Recognition",@"Voice Commands",  @"Reset all Data", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [settings count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [settings objectAtIndex:indexPath.row];
    
    if ([cell.textLabel.text isEqualToString:@"Reset all Data"]) {
        cell.textLabel.textColor = [UIColor redColor];
    }
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    if (indexPath.row == 5) {
        [CoreDataHelper nuke];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"All Data Deleted" message:@"Everything is Gone :(" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if (indexPath.row == 2) {
        UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:@"Are You Sure you want to Logout?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [actionSheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 1) {
        switch (buttonIndex) {
            case 0: {
                [PFUser logOut];
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Logged Out" message:@"You will now be returned to the login screen" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [alert show];
            }
            case 1: {
                //Do Nothing
            }
            default:
                break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        if (![PFUser currentUser]) { // No user logged in
            UIStoryboard *storyboard = self.storyboard;
            videoViewController *destVC = [storyboard instantiateViewControllerWithIdentifier:@"videoView"];
            [self.navigationController pushViewController:destVC animated:YES];
        } else {
            //Do Nothing

        }
        
    }
    else
    {
        NSLog(@"cancel");
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
