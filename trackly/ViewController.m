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

#define AVENIR_NEXT(_size) ([UIFont fontWithName:@"AvenirNext-Regular" size:(_size)])
#define WK_COLOR_GRAY_77 			WK_COLOR(77,77,77,1)

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
    UITextField *taskName;
    UITextField *taskTags;
    UILabel * createTaskLabel;
    UIView *contentView;
    AKTagsInputView *_tagsInputView;
    NSMutableArray * allTasks;
}
@end

@implementation ViewController
@synthesize //Buttons
            sync, settings, about, addTask, trayDisplayButton,
            //Labels
            sadFace, noTaskLabel,
            //Views
            tray, mainView, noTaskView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillAppear:YES];
	// Do any additional setup after loading the view, typically from a nib.
 //   mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"triangular_@2X.png"]];
    self.navigationController.navigationBar.alpha = 0.9;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mySelector:)];
    tapRecognizer.numberOfTapsRequired = 2;
    tapRecognizer.numberOfTouchesRequired = 1;
    [mainView addGestureRecognizer:tapRecognizer];
    
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
    taskName = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, 280, 50)];
    taskName.borderStyle = UITextBorderStyleRoundedRect;
    taskName.font = [UIFont systemFontOfSize:15];
    taskName.placeholder = @"Enter task name";
    taskName.autocorrectionType = UITextAutocorrectionTypeNo;
    taskName.keyboardType = UIKeyboardTypeDefault;
    taskName.keyboardAppearance = UIKeyboardAppearanceDefault;
    taskName.returnKeyType = UIReturnKeyDefault;
    taskName.clearButtonMode = UITextFieldViewModeWhileEditing;
    taskName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    taskName.delegate = self;
    taskName.layer.cornerRadius = 0.0f;
//    taskName.borderStyle =  UITextBorderStyleNone;
//    taskName.backgroundColor = [UIColor whiteColor];
    [taskName setReturnKeyType:UIReturnKeyDone];
    
//    taskTags = [[UITextField alloc] initWithFrame:CGRectMake(10, 140, 280, 50)];
//    taskTags.borderStyle = UITextBorderStyleRoundedRect;
//    taskTags.font = [UIFont systemFontOfSize:15];
//    taskTags.placeholder = @"Enter Tags (Optional)";
//    taskTags.autocorrectionType = UITextAutocorrectionTypeNo;
//    taskTags.keyboardType = UIKeyboardTypeDefault;
//    taskTags.keyboardAppearance = UIKeyboardAppearanceDark;
//    taskTags.returnKeyType = UIReturnKeyDone;
//    taskTags.clearButtonMode = UITextFieldViewModeWhileEditing;
//    taskTags.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    taskTags.delegate = self;
//    [taskTags setReturnKeyType:UIReturnKeyDone];
    
    
    

    [contentView addSubview:taskName];
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
    
//    [self firstTimeTour];
    
    //Labels font
    [[UILabel appearance] setFont:[UIFont fontWithName:@"Helvetica-Neue" size:6.0]];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor colorWithRed:255.0/255.0 green:250.0/250.0 blue:240.0/240.0 alpha:1.0], UITextAttributeTextColor,
                                                                   [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],UITextAttributeTextShadowColor,
                                                                   [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                                   UITextAttributeTextShadowOffset,
                                                                   [UIFont fontWithName:@"CoquetteRegular" size:28.0], UITextAttributeFont, nil];
    
//    [self.navigationController.navigationBar setBarTintColor:[UIColor greenColor]];
    
//    //Navbar Font
//    [self.navigationController.navigationBar setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIFont fontWithName:@"BrandonGrotesque-Light" size:32],
//      NSFontAttributeName, nil]];
    
    //Show font
//    for (NSString* family in [UIFont familyNames])
//    {
//        NSLog(@"%@", family);
//    
//        for (NSString* name in [UIFont fontNamesForFamilyName: family])
//        {
//            NSLog(@" %@", name);
//        }
//    }

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
        allTasks = [Task getAll];
    
        if ([allTasks count] > 0) {
            noTaskView.hidden = YES;
        }
    
        contentView.backgroundColor = [self colorWithHexString:@"eeeeee"];
}
-(void)hideTray {
    if (trayShown == false) {
        [menu showFromNavigationController:self.navigationController];
        mainView.backgroundColor = [UIColor blackColor];
        mainView.alpha = 0.40;
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
-(IBAction)mySelector:(id)sender {
    NSLog(@"Finger X = %f", fingerX);
    NSLog(@"Finger Y = %f", fingerY);
    
    CGPoint newCurrentlyCenter = CGPointMake(addTask.center.x, addTask.center.y - 100);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    addTask.center = newCurrentlyCenter;
    [UIView commitAnimations];
    
    CGRect rect = self.addTask.frame;
    rect.origin = CGPointMake(fingerX, fingerY);
    self.addTask.frame = rect;

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
    [alertView close];
    NSMutableArray * tags = [[NSMutableArray alloc]initWithArray:_tagsInputView.selectedTags];
    [self createAndSyncTask : taskName.text : tags];
    
    
}

-(void)createAndSyncTask : (NSString*)tempName : (NSArray*)tempTasks {
    Task * tempTask = [[Task alloc]init];
    tempTask.taskName = tempName;
    tempTask.taskTags = tempTasks;
    NSLog(@"%@", tempTask);
    
    [Task addTask:tempTask];
    
    
    //TODO IF TAGS CONTAINS TIME ASSIGN CALENDER DELEGATE
    
    //TODO SYNC TO PARSE
    
    //TODO Display the Task
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [taskTags resignFirstResponder];
    [taskName resignFirstResponder];
    return YES;
}



@end
