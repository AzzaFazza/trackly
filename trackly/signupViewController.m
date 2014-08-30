//
//  signupViewController.m
//  Taskly
//
//  Created by Adam Fallon on 31/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import "signupViewController.h"
#import "ViewController.h"
#import <FlatUIKit/FlatUIKit.h>

@interface signupViewController ()

@end

@implementation signupViewController

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
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-60.png"]]];
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tab3Blur.jpg"]]];
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateNormal];
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateHighlighted];
    
    self.signUpView.usernameField.textColor = [UIColor wetAsphaltColor];
    self.signUpView.usernameField.backgroundColor = [UIColor whiteColor];
    
    self.signUpView.passwordField.textColor = [UIColor wetAsphaltColor];
    self.signUpView.passwordField.backgroundColor = [UIColor whiteColor];
    
    self.signUpView.emailField.textColor = [UIColor wetAsphaltColor];
    self.signUpView.emailField.backgroundColor = [UIColor whiteColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
    UIStoryboard   *storyboard = self.storyboard;
    ViewController *destVC = [storyboard instantiateViewControllerWithIdentifier:@"mainView"];
    [self.navigationController pushViewController:destVC animated:YES];
}

-(void)viewDidLayoutSubviews {
    [self.signUpView.dismissButton setFrame:CGRectMake(250.0f,20.0f, 87.5f, 45.5f)];
    [self.signUpView.logo setFrame:CGRectMake(110.0f, 50.0f, 100.0f, 100.0f)];
    
    [self.signUpView.usernameField setFrame:CGRectMake(35.0f, 195.0f, 250.0f, 50.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(35.0f, 250.0f, 250.0f, 50.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(35.0f,305.0f , 250.0f, 50.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 420.0f, 250.0f, 40.0f)];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
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
