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
#import "CRProductTour.h"
#import <RNGridMenu/RNGridMenu.h>



@interface ViewController ()
{
    BOOL trayShown;
    float fingerX;
    float fingerY;
    REMenu* menu;
    CRProductTour * productTourView;
    UIView * button1;
}
@end

@implementation ViewController
@synthesize //Buttons
            sync, settings, about, addTask, trayDisplayButton,
            //Views
            tray, mainView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
 //   mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"triangular_@2X.png"]];
    self.navigationController.navigationBar.alpha = 0.9;
    trayShown = false;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mySelector:)];
    tapRecognizer.numberOfTapsRequired = 2;
    tapRecognizer.numberOfTouchesRequired = 1;
    [mainView addGestureRecognizer:tapRecognizer];
    
    fingerX = 0.0;
    fingerY = 0.0;
    
//    [self firstTimeTour];
    
    //Labels font
    [[UILabel appearance] setFont:[UIFont fontWithName:@"DIN Alternate" size:10.0]];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor greenColor]];
    
//    //Navbar Font
//    [self.navigationController.navigationBar setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIFont fontWithName:@"BrandonGrotesque-Light" size:32],
//      NSFontAttributeName, nil]];
    
/*    //Show font
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
    
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@" %@", name);
        }
    }
 */
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
    
    REMenuItem *profileItem = [[REMenuItem alloc] initWithTitle:@"About"
                                                       subtitle:@"A Little about us"
                                                          image:[UIImage imageNamed:@"Icon_Profile"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                         }];
    
    menu = [[REMenu alloc] initWithItems:@[homeItem, exploreItem, activityItem, profileItem]];
    
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

-(void)test:(RNGridMenuItem*)objectName {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Test" message:@"Test" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
    NSLog(@"Lovely Bums");
    
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
                                                               CustomIOS7AlertView * workTask = [[CustomIOS7AlertView alloc]init];
                                                               workTask.buttonTitles = [NSArray arrayWithObjects:@"Cancel", @"Set Task", nil];
                                                               [workTask show];
                                                           }];
    RNGridMenuItem * item2 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Home"
                                                           action:^{
                                                               //Do Nothing
                                                               CustomIOS7AlertView * homeTask = [[CustomIOS7AlertView alloc]init];
                                                               [homeTask show];
                                                           }];
    RNGridMenuItem * item3 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Play"
                                                           action:^{
                                                               //Do Nothing
                                                               CustomIOS7AlertView * playTask = [[CustomIOS7AlertView alloc]init];
                                                               [playTask show];
                                                           }];
    RNGridMenuItem * item4 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Events"
                                                           action:^{
                                                               //Do Nothing
                                                               CustomIOS7AlertView * eventsTask = [[CustomIOS7AlertView alloc]init];
                                                               [eventsTask show];
                                                           }];
    RNGridMenuItem * item5 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Sporting"
                                                           action:^{
                                                               //Do Nothing
                                                               CustomIOS7AlertView * sportingTask = [[CustomIOS7AlertView alloc]init];
                                                               [sportingTask show];
                                                           }];
    RNGridMenuItem * item6 = [[RNGridMenuItem alloc]initWithImage:nil
                                                            title:@"Other"
                                                           action:^{
                                                               //Do Nothing
                                                               CustomIOS7AlertView * otherTask = [[CustomIOS7AlertView alloc]init];
                                                               [otherTask show];
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

-(void) firstTimeTour {
    
}


@end
