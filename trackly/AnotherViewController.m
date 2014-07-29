//
//  AnotherViewController.m
//  FlipDemo
//
//  Created by mmt on 12/7/14.
//  Copyright (c) 2014 Michael WU. All rights reserved.
//

#import "AnotherViewController.h"
#import "MRFlipTransition.h"

@interface AnotherViewController ()

@end

@implementation AnotherViewController
@synthesize tempTask;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *launchButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 210, 60)];
    launchButton.backgroundColor = [UIColor blackColor];
    [launchButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [launchButton addTarget:self action:@selector(flyAway:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2 , 0, 210, 60)];
    nameLabel.text = tempTask.taskName;
        
    [self.view addSubview:nameLabel];
    
    [self.view addSubview:launchButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [(MRFlipTransition *)self.transitioningDelegate updateContentSnapshot:self.view afterScreenUpdate:YES];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)flyAway:(id)sender
{
    [(MRFlipTransition *)self.transitioningDelegate dismissTo:MRFlipTransitionPresentingFromInfinityAway completion:nil];
}

@end
