//
//  ViewController.m
//  trackly
//
//  Created by Adam Fallon on 18/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import "ViewController.h"
#import "REMenu.h"
#import "CustomIOS7AlertView.h"
#import <CXCardView/CXCardView.h>
#import <RNGridMenu/RNGridMenu.h>
#import "videoViewController.h"
#import <AKTagsInputView/AKTextField.h>
#import <AKTagsInputView/AKTagsInputView.h>
#import "Task.h"
#import "QuartzCore/QuartzCore.h"
#import "CoreDataHelper.h"
#import "NSManagedObject+CRUD.h"
#import "KLCPopup.h"
#import "customTableViewCell.h"

#define AVENIR_NEXT(_size) ([UIFont fontWithName:@"AvenirNext-Regular" size:(_size)])
#define WK_COLOR_GRAY_77 			WK_COLOR(77,77,77,1)
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@class Task;

@interface ViewController ()
{
    CustomIOS7AlertView * newTask;
    BOOL trayShown;
    float fingerX;
    float fingerY;
    REMenu* menu;
    UIView * button1;
    UILabel * nameLabel;
    UILabel * notesLabel;
    UITextField *taskNameTextField;
    UITextField *taskTags;
    UILabel * createTaskLabel;
    UIView *contentView;
    AKTagsInputView *_tagsInputView;
    NSMutableArray * _allTasks;
    UIImageView * imageView;
    UIBarButtonItem * barItem;
    NSString * genreLabelToPass;
}
@end

@implementation ViewController
@synthesize //Buttons
            addTask, trayDisplayButton, addTaskButton,
            //Labels
            sadFace, noTaskLabel,tasksHeaderLabel,
            //Views
            mainView, noTaskView, taskTableView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillAppear:YES];
	// Do any additional setup after loading the view, typically from a nib.
 //   mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"triangular_@2X.png"]];
    self.navigationController.navigationBar.alpha = 0.9;
    
    nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 100, 25)];
    nameLabel.text = @"TASK NAME:";
    
    notesLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 100, 25)];
    notesLabel.text = @"TAGS:";
    
    CGRect  headerFrame = CGRectMake(0, 0, 300, 50);
    UIView * header = [[UIView alloc]initWithFrame:headerFrame];
    header.layer.cornerRadius = 5.0;
    header.backgroundColor = [self colorWithHexString:@"3F51B5"];
    createTaskLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 15, 70, 25)];
    createTaskLabel.text = nil;
    createTaskLabel.textColor = [UIColor whiteColor];
    createTaskLabel.textAlignment = UITextAlignmentCenter;
    [createTaskLabel setCenter:header.center];
    [header addSubview:createTaskLabel];
    
    CGRect applicationFrame = CGRectMake(0, 0, 300, 200);
    contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 5.0;
    taskNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, 280, 50)];
    taskNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    taskNameTextField.font = [UIFont systemFontOfSize:15];
    taskNameTextField.placeholder = @"Enter task name";
    taskNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    taskNameTextField.keyboardType = UIKeyboardTypeDefault;
    taskNameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    taskNameTextField.returnKeyType = UIReturnKeyDefault;
    taskNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    taskNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    taskNameTextField.delegate = self;
    taskNameTextField.layer.cornerRadius = 0.0f;
    [taskNameTextField setReturnKeyType:UIReturnKeyDone];
    
    
    [contentView addSubview:taskNameTextField];
    [contentView addSubview:taskTags];
    [contentView addSubview:nameLabel];
    [contentView addSubview:notesLabel];
    [contentView addSubview:header];
    
    newTask = [[CustomIOS7AlertView alloc]init];
    [newTask setContainerView:contentView];
    [newTask setUseMotionEffects:TRUE];
    [newTask setDelegate:self];
    newTask.buttonTitles = [NSArray arrayWithObjects:@"Cancel", @"Set Task", nil];
    
    [contentView addSubview:[self createTagsInputView]];
    
    fingerX = 0.0;
    fingerY = 0.0;
    
    //Labels font
    [[UILabel appearance] setFont:[UIFont fontWithName:@"Helvetica-Neue" size:4.0]];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor colorWithRed:255.0/255.0 green:250.0/250.0 blue:240.0/240.0 alpha:1.0], UITextAttributeTextColor,
                                                                   [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],UITextAttributeTextShadowColor,
                                                                   [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                                   UITextAttributeTextShadowOffset,
                                                                   [UIFont fontWithName:@"CoquetteRegular" size:28.0], UITextAttributeFont, nil];
    
    
    
    //REMenu
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"Main Page"
                                                    subtitle:@"Return to Task View"
                                                       image:[UIImage imageNamed:@"Icon_Home"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                      }];
    
    REMenuItem *exploreItem = [[REMenuItem alloc] initWithTitle:@"Connectors"
                                                       subtitle:@"Add services"
                                                          image:[UIImage imageNamed:@"Icon_Explore"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             
                                                         }];
    
    REMenuItem *activityItem = [[REMenuItem alloc] initWithTitle:@"Garbage Pile"
                                                        subtitle:@"Completed Tasks"
                                                           image:[UIImage imageNamed:@"Icon_Activity"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              NSLog(@"Item: %@", item);
                                                          }];
    
    REMenuItem *profileItem = [[REMenuItem alloc] initWithTitle:@"Logout"
                                                       subtitle:@"Go Back to the start Menu"
                                                          image:[UIImage imageNamed:@"Icon_Profile"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             //push next view
                                                             UIStoryboard *storyboard = self.storyboard;
                                                             videoViewController *destVC = [storyboard instantiateViewControllerWithIdentifier:@"videoView"];
                                                             [self.navigationController pushViewController:destVC animated:YES];
                                                         }];
    
    menu = [[REMenu alloc] initWithItems:@[homeItem, exploreItem, activityItem, profileItem]];
    
    
    noTaskLabel.font = [UIFont fontWithName:@"CoquetteRegular" size:28.0f];
    sadFace.font = [UIFont fontWithName:@"CoquetteRegular" size:42.0f];
    
    noTaskView.layer.masksToBounds = NO;
    noTaskView.layer.shadowOffset = CGSizeMake(5, 5);
    noTaskView.layer.shadowRadius = 2;
    noTaskView.layer.shadowOpacity = 0.1;
    
    [self parralaxEffect];
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"syncIcon.png"]];
    imageView.autoresizingMask = UIViewAutoresizingNone;
    imageView.contentMode = UIViewContentModeCenter;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button addSubview:imageView];
    [button addTarget:self action:@selector(rotate:) forControlEvents:UIControlEventTouchUpInside];
    imageView.center = button.center;
    barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = barItem;
    
    //Load objects from CoreData
    _allTasks = [Task readAllObjectsInContext:[CoreDataHelper mainManagedObjectContext]];
    
    [taskTableView setDataSource: self];
    [taskTableView setDelegate:self];
    
    [taskTableView reloadData];
    
    if(_allTasks.count == 0) {
        taskTableView.hidden = true;
        tasksHeaderLabel.hidden = true;
        noTaskView.hidden = false;
    } else {
        taskTableView.hidden = false;
        tasksHeaderLabel.hidden = false;
        noTaskView.hidden = true;
    }
    

    
}

-(AKTagsInputView*)createTagsInputView
{
    _tagsInputView = [[AKTagsInputView alloc] initWithFrame:CGRectMake(10, 140, 280, 50)];
    _tagsInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    _tagsInputView.lookupTags = @[@""];
//    _tagsInputView.selectedTags = [NSMutableArray arrayWithArray:@[@""]];
    _tagsInputView.enableTagsLookup = YES;
    _tagsInputView.tintColor = [UIColor whiteColor];
    //_tagsInputView.placeholder = @"+ Add";
    return _tagsInputView;
}

-(void)viewWillAppear:(BOOL)animated {
        trayShown = false;
    
        if ([_allTasks count] > 0) {
            noTaskView.hidden = YES;
        }
    
    contentView.backgroundColor = [self colorWithHexString:@"eeeeee"];
    self.addTaskButton.layer.cornerRadius = 6.00;
    [mainView addSubview:[self addTaskButton]];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    
}
-(void)hideTray {
    if (trayShown == false) {
        [menu showFromNavigationController:self.navigationController];
        trayShown = true;
    } else {
        [menu close];
        trayShown = false;
        mainView.backgroundColor = [UIColor whiteColor];
        mainView.alpha = 1.00;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)test:(RNGridMenuItem*)objectName {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Test" message:@"Test" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show]; 
}

-(IBAction)showTray:(id)sender {
    [self hideTray];
}


- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    if(translation.x > -290.00 && translation.x <= 200.00) {
        if(translation.y > -430.00 && translation.y <= 430.00) {
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y + translation.y);
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        }
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touched = [[event allTouches] anyObject];
    CGPoint location = [touched locationInView:touched.view];
    NSLog(@"x=%.2f y=%.2f", location.x, location.y);
    fingerX = location.x; fingerY = location.y;
}
- (void)showList {
    RNGridMenuItem * item1 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Work"
                                                           action:^{
                                                            //Do Nothing
                                                               [newTask show];
                                                               [self createTask:@"Work"];
                                                           }];
    RNGridMenuItem * item2 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Home"
                                                           action:^{
                                                               //Do Nothing
                                                               [newTask show];
                                                               [self createTask:@"Home"];
                                                           }];
    RNGridMenuItem * item3 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Play"
                                                           action:^{
                                                               //Do Nothing
                                                               [newTask show];
                                                               [self createTask:@"Play"];
                                                           }];
    RNGridMenuItem * item4 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Events"
                                                           action:^{
                                                               //Do Nothing
                                                               [newTask show];
                                                               [self createTask:@"Events"];
                                                           }];
    RNGridMenuItem * item5 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Sporting"
                                                           action:^{
                                                               //Do Nothing
                                                               [newTask show];
                                                               [self createTask:@"Sporting"];
                                                           }];
    RNGridMenuItem * item6 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Other"
                                                           action:^{
                                                               //Do Nothing
                                                               [newTask show];
                                                               [self createTask:@"Other"];
                                                           }];
    
    NSArray *options = @[
                         item1,
                         item2,
                         item3,
                         item4,
                         item5,
                         item6
                         ];
    for (int i = 0; i < options.count; i++) {
        
    }
    
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:options];
    av.delegate = self;
    //    av.itemTextAlignment = NSTextAlignmentLeft;
    av.itemFont = [UIFont boldSystemFontOfSize:18];
    av.itemSize = CGSizeMake(150, 55);
    av.blurLevel = 0.1;
    av.animationDuration = 0.05;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
    

}
-(IBAction)addTask:(id)sender {
    [self showList];
    
    
}

-(void) createTask : (NSString*)selector{
    NSLog(@"%@", selector);
    genreLabelToPass = selector;
    createTaskLabel.text = selector;
    createTaskLabel.font = [UIFont fontWithName:@"CoquetteRegular" size:20.0];
    nameLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:8.0f];
    notesLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:8.0f];
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
    NSMutableArray * tags = [[NSMutableArray alloc]initWithArray:_tagsInputView.selectedTags];
    
    if (buttonIndex ==  1) {
        [self createAndSyncTask : taskNameTextField.text : tags :genreLabelToPass];
        NSLog(@"Created Task");
        [alertView close];
        taskNameTextField.text = @"";
    } else {
        [alertView close];
        NSLog(@"Closed task builder");
    }
    
    
}

-(void)createAndSyncTask : (NSString*)tempName : (NSMutableArray*)tempTags :(NSString *)genreLabel{
    
    Task * tempTask = [Task createObjectInContext:[CoreDataHelper mainManagedObjectContext]];
    NSString * tn = tempName;
    NSMutableArray * tnt = tempTags;
    NSString * gl = genreLabel;
    tempTask.taskName = tn;
    tempTask.taskTags = tnt;
    tempTask.taskGenre = gl;
    [Task saveOnMain];
    
    _allTasks = [Task readAllObjectsInContext:[CoreDataHelper mainManagedObjectContext]];
    if(_allTasks.count == 0) {
        //Do Nothing
    } else {
        [taskTableView reloadData];
        taskTableView.hidden = NO;
        tasksHeaderLabel.hidden = NO;
        noTaskView.hidden  = YES;
    }
    
    //TODO IF TAGS CONTAINS TIME ASSIGN CALENDER DELEGATE
    
    //TODO SYNC TO PARSE
    
    //TODO Display the Task
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [taskTags resignFirstResponder];
    [taskNameTextField resignFirstResponder];
    return YES;
}

-(void)parralaxEffect {
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-20);
    verticalMotionEffect.maximumRelativeValue = @(20);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-20);
    horizontalMotionEffect.maximumRelativeValue = @(20);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [noTaskView addMotionEffect:group];
}

- (IBAction)rotate:(id)sender
{
    _allTasks = [Task readAllObjectsInContext:[CoreDataHelper mainManagedObjectContext]];
    [taskTableView reloadData];
    
    if(_allTasks.count > 0) {
        taskTableView.hidden = false;
        tasksHeaderLabel.hidden = false;
    }
    
    
    //KLCPopup
    
    // Generate content view to present
    UIView* contentViewKLC = [[UIView alloc] init];
    contentViewKLC.translatesAutoresizingMaskIntoConstraints = NO;
    contentViewKLC.backgroundColor = [UIColor colorWithRed:(0.0/255.0) green:(204.0/255.0) blue:(134.0/255.0) alpha:1.0];
    contentViewKLC.layer.cornerRadius = 12.0;
    
    UILabel* dismissLabel = [[UILabel alloc] init];
    dismissLabel.translatesAutoresizingMaskIntoConstraints = NO;
    dismissLabel.backgroundColor = [UIColor clearColor];
    dismissLabel.textColor = [UIColor whiteColor];
    dismissLabel.font = [UIFont boldSystemFontOfSize:32.0];
    dismissLabel.text = @"Tasks Synced!";
    
    UIButton* dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    dismissButton.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    dismissButton.backgroundColor = [UIColor colorWithRed:(0.0/255.0) green:(233.0/255.0) blue:(122.0/255.0) alpha:1.0];
    [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [dismissButton setTitleColor:[[dismissButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    dismissButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [dismissButton setTitle:@"Yay" forState:UIControlStateNormal];
    dismissButton.layer.cornerRadius = 6.0;
    [dismissButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentViewKLC addSubview:dismissLabel];
    [contentViewKLC addSubview:dismissButton];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(contentViewKLC, dismissButton, dismissLabel);
    
    [contentViewKLC addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(16)-[dismissLabel]-(10)-[dismissButton]-(24)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [contentViewKLC addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(36)-[dismissLabel]-(36)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    KLCPopup* pu = [KLCPopup popupWithContentView:contentViewKLC
                                         showType:KLCPopupShowTypeBounceInFromBottom
                                         dismissType:KLCPopupDismissTypeBounceOutToBottom
                                         maskType:KLCPopupMaskTypeDimmed
                                         dismissOnBackgroundTouch:YES
                                         dismissOnContentTouch:YES];
    
    
    [UIView beginAnimations:@"step1" context:NULL]; {
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
        imageView.transform = CGAffineTransformMakeRotation(120 * M_PI / 180);
         } [UIView commitAnimations];
    
    [pu show];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
        {
            if ([animationID isEqualToString:@"step1"]) {
                [UIView beginAnimations:@"step2" context:NULL]; {
                    [UIView setAnimationDuration:1.0];
                    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
                    [UIView setAnimationDelegate:self];
                    imageView.transform = CGAffineTransformMakeRotation(240 * M_PI / 180);
                } [UIView commitAnimations];
            }
            else if ([animationID isEqualToString:@"step2"]) {
                [UIView beginAnimations:@"step3" context:NULL]; {
                    [UIView setAnimationDuration:1.0];
                    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
                    [UIView setAnimationDelegate:self];
                    imageView.transform = CGAffineTransformMakeRotation(0);
                } [UIView commitAnimations];
            }
}

//Table View stuff
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[Task readAllObjectsInContext:[CoreDataHelper mainManagedObjectContext]] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // For anything in the UI use main managed object context
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"customTableViewCell";
    customTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Task *tempTask = [_allTasks objectAtIndex:indexPath.section];
    
    // Just presenting some details
    NSString *taskDetails = [NSString stringWithFormat:@"%@", tempTask.taskName];
    NSLog(@"%@", tempTask.taskName);
   cell.taskNameLabel.text = [NSString stringWithFormat:@"%@", taskDetails ];
   cell.tagsLabel.text = [NSString stringWithFormat:@"%@", [tempTask.taskTags componentsJoinedByString:@"   "]];
    cell.taskGenre.text = [NSString stringWithFormat:@"%@", tempTask.taskGenre];
    
    [taskTableView setClipsToBounds:YES];
    
    
    cell.imageView.image = [UIImage imageNamed:@"Icon_Activity.png"];
    
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [Task deleteObject:[_allTasks objectAtIndex:indexPath.section] inContext:[CoreDataHelper mainManagedObjectContext]];
        [taskTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [self allTasksComplete];
        [taskTableView reloadData];
        [Task saveOnMain];
        _allTasks = [Task readAllObjectsInContext:[CoreDataHelper mainManagedObjectContext]];
        if(_allTasks.count == 0)
        {
            taskTableView.hidden = YES;
            tasksHeaderLabel.hidden = YES;
            noTaskView.hidden = NO;
            [self allTasksComplete];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

-(void) allTasksComplete {
    if(_allTasks.count == 0) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"All Tasks Complete!" message:@"No More tasks left, Well Done!" delegate:nil cancelButtonTitle:@"Okay!" otherButtonTitles:nil, nil];
        [alert show];
        taskTableView.hidden  = true;
        tasksHeaderLabel.hidden = true;
        [taskTableView reloadData];
    }
}
- (void)dismissButtonPressed:(id)sender {
    if ([sender isKindOfClass:[UIView class]]) {
        [(UIView*)sender dismissPresentingPopup];
    }
}



@end
