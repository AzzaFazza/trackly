//
//  ViewController.m
//  trackly
//
//  Created by Adam Fallon on 18/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

//Custom
#import "ViewController.h"
#import "customTableViewCell.h"
#import "connectorsViewController.h"
#import "videoViewController.h"
#import "AnotherViewController.h"
#import "calandarView.h"
#import "settingsTableViewController.h"


//Frameworks + Cocoa Controls
#import "REMenu.h"
#import "CustomIOS7AlertView.h"
#import <CXCardView/CXCardView.h>
#import <RNGridMenu/RNGridMenu.h>
#import <AKTagsInputView/AKTextField.h>
#import <AKTagsInputView/AKTagsInputView.h>
#import "QuartzCore/QuartzCore.h"
#import "KLCPopup.h"
#import <JBKenBurnsView/JBKenBurnsView.h>
#import <QuartzCore/QuartzCore.h>
#import "MRFlipTransition.h"
#import <CWStatusBarNotification/CWStatusBarNotification.h>


//Core Data
#import "CoreDataHelper.h"
#import "NSManagedObject+CRUD.h"
#import "Task.h"

//Parse
#import <Parse/Parse.h>

//Open Ears
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>


//Defined Attributes
#define AVENIR_NEXT(_size) ([UIFont fontWithName:@"AvenirNext-Regular" size:(_size)])
#define WK_COLOR_GRAY_77 			WK_COLOR(77,77,77,1)
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@class Task;

@interface ViewController ()
{

    //Primitives
    BOOL trayShown;
    BOOL * searchShown;
    float fingerX;
    float fingerY;
    NSInteger currentCellToEditNumber;
    
    //Custom UI
    CustomIOS7AlertView * newTask;
    REMenu* menu;
    AKTagsInputView *_tagsInputView;
    customTableViewCell *cell;
    
    //UI
    UIView * button1;
    UIView *contentView;
    
    UILabel * nameLabel;
    UILabel * notesLabel;
    UILabel * createTaskLabel;
    
    UIImageView * imageView;
    UIImageView * imageView2;
    UIImageView * imageView3;
    UIImageView * imageView4;
    
    UIBarButtonItem * barItem;
    UIBarButtonItem * barItem2;
    UIBarButtonItem * barItem3;
    UIBarButtonItem * barItem4;
    
    NSString * genreLabelToPass;
    MRFlipTransition *animator;
    
    
    //Gestures
    UITapGestureRecognizer *tap;
    
    //Core Data
    NSData *imageData;
    UITextField *taskNameTextField;
    UITextField *taskTags;
    NSMutableArray * _allTasks;
    
    //Parse
    PFUser * user;
    
    //Open Ears
    LanguageModelGenerator * lmGenerator;
    PocketsphinxController * pocketSphinxController;
    OpenEarsEventsObserver *openEarsEventsObserver;
    NSString *lmPath;
    NSString *dicPath;
    NSArray * words;
    
    //Notifications
    CWStatusBarNotification * listening;
}

@property (strong, nonatomic) PocketsphinxController * pocketSphinxController;
@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;

@end

@implementation ViewController
@synthesize //Buttons
            trayDisplayButton, addTaskButton,
            //Labels
            sadFace, noTaskLabel,tasksHeaderLabel,
            //Views
            mainView, noTaskView, taskTableView, searchBar,
            //OpenEars
            pocketSphinxController, openEarsEventsObserver
            ;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillAppear:YES];
	// Do any additional setup after loading the view, typically from a nib.
 //   mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"triangular_@2X.png"]];
    
    //Open Ears
    lmGenerator = [[LanguageModelGenerator alloc]init];
    words = [NSArray arrayWithObjects:          @"NOTE",
                                                @"TASKLY",
                                                @"TASKLY OPEN NOTES",
                                                @"TASKLY OPEN CALENDAR",
                                                @"TASKLY OPEN CONNECTORS",
                                                @"TASKLY NOTE",
                                                @"TASKLY NEW NOTE",
                                                @"TASKLY TAKE A NOTE",
                                                @"CALENDAR",
                                                @"NOTES",
                                                @"CONNECTORS",
                                                @"NEW NOTE",
                                                @"OPEN CALENDAR",
                                                nil];
    NSString  *  name  = @"TASKLY_COMMANDS";
    NSError   *  err   = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
    NSDictionary * languageGeneratorResults = nil;
    lmPath = nil;
    dicPath = nil;
    
    if ([err code] == noErr) {
        languageGeneratorResults = [err userInfo];
        
        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
    } else {
        NSLog(@"Error : %@", [err localizedDescription]);
    }
    
    [self StartListening];
    
    //Custom UI Setup
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
    
    imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search.png"]];
    imageView2.autoresizingMask = UIViewAutoresizingNone;
    imageView2.contentMode = UIViewContentModeCenter;
    
    imageView3 =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"advanced.png"]];
    imageView3.autoresizingMask = UIViewAutoresizingNone;
    imageView3.contentMode = UIViewContentModeCenter;
    
    imageView4 =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"date3.png"]];
    imageView4.autoresizingMask = UIViewAutoresizingNone;
    imageView4.contentMode = UIViewContentModeCenter;
    
    //Sync
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button addSubview:imageView];
    [button addTarget:self action:@selector(rotate:) forControlEvents:UIControlEventTouchUpInside];
    imageView.center = button.center;
    barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //Search
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(0, 0, 40, 40);
    [button2 addSubview:imageView2];
    [button2 addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    imageView2.center = button.center;
    barItem2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    
    //Settings
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(0, 0, 40, 40);
    [button3 addSubview:imageView3];
    [button3 addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    imageView3.center = button.center;
    barItem3 = [[UIBarButtonItem alloc] initWithCustomView:button3];
    
    //Calendar
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectMake(0, 0, 40, 40);
    [button4 addSubview:imageView4];
    [button4 addTarget:self action:@selector(showCalendar) forControlEvents:UIControlEventTouchUpInside];
    imageView4.center = button.center;
    barItem4 = [[UIBarButtonItem alloc] initWithCustomView:button4];
    
    NSArray * rightNavButtons = [NSArray arrayWithObjects:barItem2, barItem, nil];
    NSArray * leftNavButtons = [NSArray arrayWithObjects:barItem3, barItem4, nil];
    self.navigationItem.rightBarButtonItems = rightNavButtons;
    self.navigationItem.leftBarButtonItems = leftNavButtons;
    
    //Labels font
    [[UILabel appearance] setFont:[UIFont fontWithName:@"Helvetica-Neue" size:4.0]];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor colorWithRed:255.0/255.0 green:250.0/250.0 blue:240.0/240.0 alpha:1.0], UITextAttributeTextColor,
                                                                   [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],UITextAttributeTextShadowColor,
                                                                   [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                                   UITextAttributeTextShadowOffset,
                                                                   [UIFont fontWithName:@"CoquetteRegular" size:28.0], UITextAttributeFont, nil];

    //Load objects from CoreData
    _allTasks = [Task readAllObjectsInContext:[CoreDataHelper mainManagedObjectContext]];
    
    //TableData Setup
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
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }

    
}
-(void)viewDidAppear:(BOOL)animated {
    searchShown = false;
    if(_allTasks.count == 0) {
        taskTableView.hidden = true;
        tasksHeaderLabel.hidden = true;
        noTaskView.hidden = false;
    } else {
        taskTableView.hidden = false;
        tasksHeaderLabel.hidden = false;
        noTaskView.hidden = true;
    }
    
    [taskTableView reloadData];
}

-(void)showCalendar {
    UIStoryboard *storyboard = self.storyboard;
    calandarView *destVC = [storyboard instantiateViewControllerWithIdentifier:@"Calandar"];
    [self.navigationController pushViewController:destVC animated:YES];
}
-(void)showSettings {
    UIStoryboard *storyboard = self.storyboard;
    settingsTableViewController *destVC = [storyboard instantiateViewControllerWithIdentifier:@"Settings"];
    [self.navigationController pushViewController:destVC animated:YES];
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
-(void)viewDidDisappear:(BOOL)animated {
    [self  StopListening];
}

-(void)StopListening {
    
}

-(void)viewWillAppear:(BOOL)animated {
    searchBar.hidden = true;
    trayShown = false;
        if ([_allTasks count] > 0) {
            noTaskView.hidden = YES;
        }
    
    contentView.backgroundColor = [self colorWithHexString:@"eeeeee"];
    
    //Set up Flat button for the add task button
    addTaskButton.buttonColor = [self colorWithHexString:@"3F51B5"];
    addTaskButton.shadowColor = [self colorWithHexString:@"33439C"];
    addTaskButton.shadowHeight = 3.0f;
    addTaskButton.cornerRadius = 6.0f;
    
    //Task button add to navigation bar
    addTaskButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [addTaskButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [addTaskButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
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
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showTray:(id)sender {
    [self hideTray];
}


//Here we have the menu that appears when the add task button is pressed. From this view users can then add a new task to the task DB
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
    av.itemFont = [UIFont boldSystemFontOfSize:18];
    av.itemSize = CGSizeMake(150, 55);
    av.blurLevel = 0.1;
    av.animationDuration = 0.05;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
    
}

//Show the drop down menu !IMPORTANT
-(IBAction)addTask:(id)sender {
    [self showList];

}

//TODO REFACTOR THIS - Missnamed Method (The method only gets the selected)
-(void) createTask : (NSString*)selector{
    NSLog(@"%@", selector);
    genreLabelToPass = selector;
    createTaskLabel.text = selector;
    createTaskLabel.font = [UIFont fontWithName:@"CoquetteRegular" size:20.0];
    nameLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:8.0f];
    notesLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:8.0f];
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
    
    //TODO CHECK INTERNET
    PFObject *taskToSyncToParse = [PFObject objectWithClassName:@"Tasks"];
    taskToSyncToParse[@"TaskName"] = tn;
    taskToSyncToParse[@"TaskTags"] = tnt;
    taskToSyncToParse[@"TaskGenre"] = gl;
    
    //Assign this task to Parse User
    user = [PFUser currentUser];
    
    [taskToSyncToParse saveEventually:^(BOOL succeeded, NSError *error)
    {
        if (succeeded)
        {
            PFRelation *relation = [user relationforKey:@"Tasks"];
            [relation addObject:taskToSyncToParse];
            [user saveInBackground];
        }
    }];
    
    //TODO Display the Task
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [taskTags resignFirstResponder];
    [taskNameTextField resignFirstResponder];
    return YES;
}

- (IBAction)rotate:(id)sender
{
    _allTasks = [Task readAllObjectsInContext:[CoreDataHelper mainManagedObjectContext]];
    [self retrieveUsersParseTasks];
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

-(void)retrieveUsersParseTasks {
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"Tasks"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(!error) {
            NSLog(@"Successfully retrieved %d Tasks.", results.count);
            // Do something with the found objects
            for (PFObject *object in results) {
                NSLog(@"%@", object);
                [taskTableView reloadData];
            }
        } else {
            NSLog(@"%@Error", error);
        }
    }];
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
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Task *tempTask = [_allTasks objectAtIndex:indexPath.section];
    
    // Just presenting some details
    NSString *taskDetails = [NSString stringWithFormat:@"%@", tempTask.taskName];
    NSLog(@"%@", tempTask.taskName);
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    cell.taskNameLabel.text = [NSString stringWithFormat:@"%@", taskDetails ];
    cell.taskNameLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0f];
    cell.taskNameLabel.numberOfLines = 2;
    cell.taskNameLabel.minimumScaleFactor = 8./cell.taskNameLabel.font.pointSize;
    cell.taskNameLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.tagsLabel.text = [NSString stringWithFormat:@"%@", [tempTask.taskTags componentsJoinedByString:@"   "]];
    cell.tagsLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:10.0f];
    
    cell.taskGenre.text = [NSString stringWithFormat:@"%@", tempTask.taskGenre];
    cell.taskGenre.font = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0f];
    
    //Appearance of the cell view
    cell.cellView.layer.cornerRadius = 3.0;
    cell.cellView.layer.masksToBounds = NO;
    cell.cellView.layer.shadowOffset = CGSizeMake(-15, 20);
    cell.cellView.layer.shadowRadius = 5;
    cell.cellView.layer.shadowOpacity = 0.5;
    cell.cellView.clipsToBounds = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [taskTableView setClipsToBounds:YES];
    
    
    UIImage *tempImage = [UIImage imageWithData:tempTask.taskImage];

    
    //Tap to change image
    [cell.cameraButton addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
    [cell.cameraButton setUserInteractionEnabled:YES];
    cell.cameraButton.tag = indexPath.section;
    
    cell.imageView.image = tempImage;
    
    //Ken Burns transition
    if(cell.imageView.image != nil) {
        NSArray * myImages = [NSArray arrayWithObject:cell.imageView.image];
        [cell.movingImages animateWithImages:myImages
                      transitionDuration:20
                            initialDelay:0
                                    loop:YES
                             isLandscape:YES];
        cell.movingImages.alpha = 0.3;
        cell.movingImages.opaque = NO;
    } else {
        //Do Nothing
         cell.movingImages.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"triangular_@2X.png"]];
    }
    
    return cell;
}

- (void)addImage:(UIButton*)sender
{
    currentCellToEditNumber = sender.tag;
    UIActionSheet * sheet = [[UIActionSheet alloc]initWithTitle:@"Select Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Library", @"From Camera", nil];
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 2) {
        UIImagePickerController * imagePicker = [[UIImagePickerController alloc]init];
        UIImagePickerControllerSourceType type;
        
        switch (buttonIndex) {
            case 0:
                type = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 1:
                type = UIImagePickerControllerSourceTypeCamera;
            default:
                break;
        }
        imagePicker.sourceType = type;
        imagePicker.delegate = self;
        [imagePicker setAllowsEditing:YES];
        imagePicker.navigationBar.barStyle = UIBarStyleBlackOpaque;
        imagePicker.navigationBar.translucent = NO;
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:imagePicker animated:YES completion:^{}];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //Take the image that the user took
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    //Convert that to binary data so Core Data can save it
    imageData = [NSData dataWithData:UIImagePNGRepresentation(chosenImage)];
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    
    // Save image.
    [imageData writeToFile:filePath atomically:YES];
    
    Task * tempTask = [_allTasks objectAtIndex:currentCellToEditNumber];
    
    tempTask.taskImage = imageData;
    [tempTask setValue:imageData forKeyPath:@"taskImage"];
    [Task saveOnMain];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [taskTableView reloadData];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    self->animator = [[MRFlipTransition alloc] initWithPresentingViewController:self presentBlock:^UIViewController *{
        AnotherViewController * anvc = [[AnotherViewController alloc]init];
        Task *tempTask = [_allTasks objectAtIndex:indexPath.section];
        anvc.tempTask = tempTask;
        
        return anvc;
    }];
    [self->animator presentFrom:MRFlipTransitionPresentingFromBottom completion:nil];
}


//TODO Make this nicer looking
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

//UI RICE BEYOND THIS POINT

//This method allows us to write colors in HEX as oposed to writing RGB values
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

-(void)search {
    //Do nothing
    
    if (!searchShown) {
        searchBar.hidden = false;
        searchShown = true;
    } else {
        searchBar.hidden = true;
        searchShown = false;
    }
}


//Open Ears
- (PocketsphinxController *)pocketSphinxController {
    if (pocketSphinxController == nil) {
        pocketSphinxController = [[PocketsphinxController alloc] init];
    }
    return pocketSphinxController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
    if (openEarsEventsObserver == nil) {
        openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
    }
    return openEarsEventsObserver;
}
- (void) StartListening {
    
    // startListeningWithLanguageModelAtPath:dictionaryAtPath:languageModelIsJSGF always needs to know the grammar file being used,
    // the dictionary file being used, and whether the grammar is a JSGF. You must put in the correct value for languageModelIsJSGF.
    // Inside of a single recognition loop, you can only use JSGF grammars or ARPA grammars, you can't switch between the two types.
    
    // An ARPA grammar is the kind with a .languagemodel or .DMP file, and a JSGF grammar is the kind with a .gram file.
    
    // If you wanted to just perform recognition on an isolated wav file for testing, you could do it as follows:
    
    // NSString *wavPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"test.wav"];
    //[self.pocketsphinxController runRecognitionOnWavFileAtPath:wavPath usingLanguageModelAtPath:self.pathToGrammarToStartAppWith dictionaryAtPath:self.pathToDictionaryToStartAppWith languageModelIsJSGF:FALSE];  // Starts the recognition loop.
    
    // But under normal circumstances you'll probably want to do continuous recognition as follows:
    [self.openEarsEventsObserver setDelegate:self];
    [self.pocketSphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
}

- (void)pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    if ([hypothesis isEqualToString: @"NEW NOTE"]) {
        [self showList];
    }
    
    if ([hypothesis isEqualToString: @"CALENDAR"]) {
        UIStoryboard *storyboard = self.storyboard;
        calandarView *destVC = [storyboard instantiateViewControllerWithIdentifier:@"Calandar"];
        [self.navigationController pushViewController:destVC animated:YES];
    }
    
}

- (void) pocketsphinxDidStartCalibration {
    NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
    NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
    
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
//    listening = [CWStatusBarNotification new];
//    listening.notificationLabelBackgroundColor = [UIColor redColor];
//    listening.notificationLabelTextColor = [UIColor whiteColor];
//    [listening displayNotificationWithMessage:@"Detecting Speech" forDuration:0.7f];
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
//    listening = [CWStatusBarNotification new];
//    listening.notificationLabelBackgroundColor = [UIColor emerlandColor];
//    listening.notificationLabelTextColor = [UIColor whiteColor];
//    [listening displayNotificationWithMessage:@"Processing..." forDuration:1.0f];
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
    NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

@end
