//
//  AFViewController.h
//  AFViewShaker
//
//  Created by Philip Vasilchenko on 23.05.14.
//  Copyright (c) 2014 okolodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <JBKenBurnsView/JBKenBurnsView.h>

@interface AFViewController : PFLogInViewController

@property (weak, nonatomic) IBOutlet   JBKenBurnsView *movingImages;

@end
