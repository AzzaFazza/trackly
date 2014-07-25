//
//  connectorsViewController.m
//  Taskly
//
//  Created by Adam Fallon on 24/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import "connectorsViewController.h"

@interface connectorsViewController ()

@end

@implementation connectorsViewController
@synthesize Exchange, Asana, GoogleCalender, Evernote, GitHub, Trello;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Generic Fallback for Buttons
    [[FUIButton appearance]setCornerRadius:3.];
    [[FUIButton appearance]setButtonColor:[UIColor emerlandColor]];
    [[FUIButton appearance]setShadowColor:[UIColor nephritisColor]];
    [[FUIButton appearance]setShadowHeight:3.0f];
    [[FUIButton appearance]setCornerRadius:6.0f];
    [[FUIButton appearance] setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [[FUIButton appearance] setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
