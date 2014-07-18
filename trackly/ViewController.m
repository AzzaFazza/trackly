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
#import <RNGridMenu/RNGridMenu.h>



@interface ViewController ()
{
    BOOL trayShown;
    float fingerX;
    float fingerY;
    REMenu* menu;
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
    trayShown = false;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mySelector:)];
    tapRecognizer.numberOfTapsRequired = 2;
    tapRecognizer.numberOfTouchesRequired = 1;
    [mainView addGestureRecognizer:tapRecognizer];
    
    fingerX = 0.0;
    fingerY = 0.0;
    
    //Labels font
    [[UILabel appearance] setFont:[UIFont fontWithName:@"DIN Alternate" size:10.0]];
    
//    //Navbar Font
//    [self.navigationController.navigationBar setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIFont fontWithName:@"DIN Alternate" size:32],
//      NSFontAttributeName, nil]];
//    
//    //Show font
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
    NSInteger numberOfOptions = 6;
    NSArray *options = @[
                         @"Work",
                         @"Home",
                         @"Play",
                         @"Events",
                         @"Sporting",
                         @"Other"
                         ];
    RNGridMenu *av = [[RNGridMenu alloc] initWithTitles:[options subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    //    av.itemTextAlignment = NSTextAlignmentLeft;
    av.itemFont = [UIFont boldSystemFontOfSize:18];
    av.itemSize = CGSizeMake(150, 55);
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}
-(IBAction)addTask:(id)sender {
    [self showList];
    
}

@end
