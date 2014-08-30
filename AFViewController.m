//
//  AFViewController.m
//  AFViewShaker
//
//  Created by Philip Vasilchenko on 23.05.14.
//  Copyright (c) 2014 okolodev. All rights reserved.
//

#import "AFViewController.h"
#import "AFViewShaker.h"
#import <FlatUIKit/FlatUIKit.h>
#import "ViewController.h"


@interface AFViewController () {
    FUIButton * myButton;
}
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray * allTextFields;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray * allButtons;
@property (nonatomic, strong) AFViewShaker * viewShaker;
@end


@implementation AFViewController
@synthesize movingImages;
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.viewShaker = [[AFViewShaker alloc] initWithViewsArray:self.allTextFields];
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tab3Blur.jpg"]]];
    
    
//    [self.logInView setBackgroundColor: [self colorWithHexString:@"3F51B5"]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-60.png"]]];
    
    [self.logInView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateNormal];
    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateHighlighted];
    
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:225.0f/255.0f alpha:1.0]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0]];
    
    [self.logInView.logInButton setImage:[UIImage imageNamed:@"loginButton.png"] forState:UIControlStateNormal];
    [self.logInView.logInButton setImage:[UIImage imageNamed:@"loginButton.png"] forState:UIControlStateHighlighted];
    
//    [self.logInView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
//    [self.logInView.signUpButton setImage:[UIImage imageNamed:@"signinButton.png"] forState:UIControlStateNormal];
//    [self.logInView.signUpButton setImage:[UIImage imageNamed:@"signinButton.png"] forState:UIControlStateHighlighted];

    self.logInView.signUpLabel.textColor = [UIColor cloudsColor];
    self.logInView.signUpLabel.font = [UIFont boldFlatFontOfSize:16];
    
    [self.logInView.usernameField setBackgroundColor:[UIColor whiteColor]];
    [self.logInView.passwordField setBackgroundColor:[UIColor whiteColor]];
    
    [self.logInView.usernameField setTextColor:[UIColor wetAsphaltColor]];
    [self.logInView.passwordField setTextColor:[UIColor wetAsphaltColor]];

    
    
    for (UIButton * button in self.allButtons) {
        button.layer.cornerRadius = 5;
    }
    
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    [self.logInView.dismissButton setFrame:CGRectMake(250.0f,20.0f, 87.5f, 45.5f)];
    [self.logInView.logo setFrame:CGRectMake(110.0f, 50.0f, 100.0f, 100.0f)];
    [self.logInView.facebookButton setFrame:CGRectMake(35.0f, 287.0f, 120.0f, 40.0f)];
    [self.logInView.twitterButton setFrame:CGRectMake(35.0f+130.0f, 287.0f, 120.0f, 40.0f)];
    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 420.0f, 250.0f, 40.0f)];
    [self.logInView.usernameField setFrame:CGRectMake(35.0f, 195.0f, 250.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(35.0f, 250.0f, 250.0f, 50.0f)];
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(15.0f, 210.0f, 20.0f, 50.0f)];
    [self.logInView addSubview:movingImages];
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - Actions

- (IBAction)onShakeOneAction:(UIButton *)sender {
    [[[AFViewShaker alloc] initWithView:self.allButtons[0]] shake];
}


- (IBAction)onShakeAllAction:(UIButton *)sender {
    [self.viewShaker shake];
}


- (IBAction)onShakeAllWithBlockAction:(UIButton *)sender {
    [self.viewShaker shakeWithDuration:0.6 completion:^{
        [[[UIAlertView alloc] initWithTitle:@"Hello"
                                   message:@"This is completions block"
                                  delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil] show];
    }];
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
@end
