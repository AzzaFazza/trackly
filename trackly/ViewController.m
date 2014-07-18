//
//  ViewController.m
//  trackly
//
//  Created by Adam Fallon on 18/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    BOOL trayShown;
}
@end

@implementation ViewController
@synthesize //Buttons
            sync, settings, about, addTask, trayDisplayButton,
            //Views
            tray;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    trayShown = false;
    tray.alpha = 0.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showTray:(id)sender {
    if(trayShown == false) {
        trayShown = true;
        [UIView beginAnimations:@"ShowHideView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(showHideDidStop:finished:context:)];
        // Make the animatable changes.        
        tray.alpha = 0.0;
        // Commit the changes and perform the animation.
        [UIView commitAnimations];
    } else {
        trayShown = false;
        [UIView beginAnimations:@"ShowHideView2" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(showHideDidStop:finished:context:)];
        // Make the animatable changes.
        
        tray.alpha = 1.0;
        // Commit the changes and pe
        
    }
}

@end
