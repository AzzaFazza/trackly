//
//  ViewController.m
//  VideoCover
//
//  Created by Bi Chen Ka Kit on 2/6/14.
//  Copyright (c) 2014年 biworks. All rights reserved.
//

#import "videoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import "CustomIOS7AlertView.h"
#import "loginViewController.h"
#import "Reachability.h"
#import "AFViewController.h"
#import "signupViewController.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface videoViewController () {
    CustomIOS7AlertView * loginView;
    Reachability *internetReachableFoo;
    BOOL internet;
}

@property (nonatomic, strong) AVPlayer *avplayer;
@property (strong, nonatomic) IBOutlet UIView *movieView;
@property (strong, nonatomic) IBOutlet UIView *gradientView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation videoViewController
@synthesize subTitle, startButton, arrow, title;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)testInternetConnection
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
            internet = YES;
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            internet = NO;
        });
    };
    
    [internetReachableFoo startNotifier];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    internet = NO;
    [self testInternetConnection];

    if (![PFUser currentUser]) { // No user logged in
        NSLog(@"No User Logged In Yet");
    } else {
        //If currentuser is logged in then push to the main view
        UIStoryboard *storyboard = self.storyboard;
        videoViewController *destVC = [storyboard instantiateViewControllerWithIdentifier:@"mainView"];
        [self.navigationController pushViewController:destVC animated:YES];
        
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:YES];
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"aValue"]]) {
        //TODO CHANGE THIS IN PRODUCTION!!
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"aValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
            
        
    // Do any additional setup after loading the view from its nib.
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *moviePath = [bundle pathForResource:@"introVid" ofType:@"mov"];
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [avPlayerLayer setFrame:self.view.frame];
    [self.movieView.layer addSublayer:avPlayerLayer];

    //Not affecting background music playing
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    [self.avplayer seekToTime:kCMTimeZero];
    [self.avplayer setVolume:0.0f];
    [self.avplayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avplayer currentItem]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.gradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0x030303) CGColor], (id)[[UIColor clearColor] CGColor], (id)[UIColorFromRGB(0x030303) CGColor],nil];
    [self.gradientView.layer insertSublayer:gradient atIndex:0];
        
    } else {
        [self skipView];
        NSMutableArray * myArray = [[NSMutableArray alloc]init];
        NSString *myString = myArray;
    }
    
    //Labels font
    subTitle.font = [UIFont fontWithName:@"CoquetteRegular" size:16.0];
    title.font = [UIFont fontWithName:@"CoquetteRegular" size:74.0];
    
    // image drawing code here
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.avplayer pause];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self testInternetConnection];
    [self.avplayer play];
    startButton.buttonColor = [self colorWithHexString:@"3F51B5"];
    startButton.shadowColor = [self colorWithHexString:@"33439C"];
    startButton.shadowHeight = 3.0f;
    startButton.cornerRadius = 6.0f;
    startButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [startButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
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
    [self.contentView addMotionEffect:group];
    
    //My introduction
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"intro"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"intro"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //MyIntro
        [self buildIntro];

        
    }
    
    [self flashingAnimation:YES forView:arrow];
    
}
-(void)buildIntro{
//    for (NSString* family in [UIFont familyNames])
//    {
//        NSLog(@"%@", family);
//        
//        for (NSString* name in [UIFont fontNamesForFamilyName: family])
//        {
//            NSLog(@" %@", name);
//        }
//    }
    //Create Stock Panel with header
    
    UIView *headerView = [[NSBundle mainBundle] loadNibNamed:@"TestHeader" owner:nil options:nil][0];
    
    NSString * titleString = @"Keep\ntrack of\nEverything";
    NSString * panel2String = @"By creating a Taskly account you can access Taskly CloudSync.\n\nBack up your tasklist across devices";
    NSString * panel4String = @"Control Taskly with your voice\n\n Say 'New Note' to create a new note\n\n Or Say 'Calendar' to take you there (Full List availble in Settings)";
    
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Welcome to Taskly" description:titleString image:[UIImage imageNamed:nil] header:headerView];
    
    //Create Stock Panel With Image
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Sync Across Devices" description:panel2String image:[UIImage imageNamed:@"cloudSync.png"]];
    
    MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Use Your Voice" description:panel4String image:[UIImage imageNamed:@"Mic.png"]];
    //1
    panel1.PanelDescriptionLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:60.];
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);

    CGSize expectedLabelSize = [titleString sizeWithFont:panel1.PanelDescriptionLabel.font constrainedToSize:maximumLabelSize lineBreakMode:panel1.PanelDescriptionLabel.lineBreakMode];
    
    CGRect newFrame = panel1.PanelDescriptionLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    panel1.PanelDescriptionLabel.frame = newFrame;
    
    //2
    panel2.PanelDescriptionLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:24.];
    CGSize maximumLabelSize2 = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize2 = [panel2String sizeWithFont:panel2.PanelDescriptionLabel.font constrainedToSize:maximumLabelSize2 lineBreakMode:panel2.PanelDescriptionLabel.lineBreakMode];
    
    CGRect newFrame2 = panel2.PanelDescriptionLabel.frame;
    newFrame2.size.height = expectedLabelSize2.height;
    panel2.PanelDescriptionLabel.frame = newFrame2;
    //4
    panel4.PanelDescriptionLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18.];
    CGSize maximumLabelSize4 = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize4 = [panel4String sizeWithFont:panel4.PanelDescriptionLabel.font constrainedToSize:maximumLabelSize4 lineBreakMode:panel4.PanelDescriptionLabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame4 = panel4.PanelDescriptionLabel.frame;
    newFrame4.size.height = expectedLabelSize4.height;
    panel4.PanelDescriptionLabel.frame = newFrame4;
    
    //Add panels to an array
    NSArray *panels = @[panel1, panel2, panel4];
    
    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    introductionView.delegate = self;
    introductionView.BackgroundImageView.image = [UIImage imageNamed:@"tab3.jpg"];
    [introductionView setBackgroundColor:[UIColor colorWithRed:63.0f/255.0f green:81.0f/255.0f blue:181.0f/255.0f alpha:0.50]];
    //introductionView.LanguageDirection = MYLanguageDirectionRightToLeft;
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:panels];
    
    //Add the introduction to your view
    [self.view addSubview:introductionView];
}
-(void)flashingAnimation:(BOOL)boolVal forView:(UIView *) view{
    [UIView animateWithDuration:0.7
                          delay:0.0
                        options:UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse
                     animations:^{
                         CGRect frame =  arrow.frame;
                         frame.origin.x += 5.0f;
                         // This is just for the width, but you can change the origin and the height as well.
                         arrow.frame = frame;
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                         CGRect frame =  arrow.frame;
                         frame.origin.x -= 5.0f;
                         // This is just for the width, but you can change the origin and the height as well.
                         arrow.frame = frame;
                     }];
    [UIView commitAnimations];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (IBAction)buttonPressed:(id)sender {
    ViewController *viewController = [[ViewController alloc]initWithNibName:@"mainView" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)skipView {
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mainView"];
    // OR myViewController *vc = [[myViewController alloc] init];
    
    // any setup code for *vc
    
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


//Parse Stuff

-(IBAction)signIn:(id)sender {
    if (internet == YES) {
    if (![PFUser currentUser]) { // No user logged in
//        // Create the log in view controller
//        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
//        [logInViewController setDelegate:self]; // Set ourselves as the delegate
//        
//        // Create the sign up view controller
//        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
//        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
//        
//        // Assign our sign up controller to be displayed from the login controller
//        [logInViewController setSignUpController:signUpViewController];
        
        AFViewController * logInViewController = [[AFViewController alloc]init];
        [logInViewController setDelegate:self];
        [logInViewController setFields:PFLogInFieldsUsernameAndPassword
         | PFLogInFieldsSignUpButton
         | PFLogInFieldsPasswordForgotten
         | PFLogInFieldsDismissButton];
        
        signupViewController *signUpViewController = [[signupViewController alloc] init];
        [signUpViewController setDelegate:self];
        [signUpViewController setFields:PFSignUpFieldsDefault];
        
        // Link the sign up view controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    } else {
        //If currentuser is logged in then push to the main view
        UIStoryboard *storyboard = self.storyboard;
        ViewController *destVC = [storyboard instantiateViewControllerWithIdentifier:@"mainView"];
        [self.navigationController pushViewController:destVC animated:YES];

        }
    } else {
        UIAlertView * noInternet = [[UIAlertView alloc]initWithTitle:@"No Internet Conenction" message:@"You Need to be Connected to the internet to Sign up or Register for Taskly" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [noInternet show];
        
    }
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    UIStoryboard *storyboard = self.storyboard;
    ViewController *destVC = [storyboard instantiateViewControllerWithIdentifier:@"mainView"];
    [self.navigationController pushViewController:destVC animated:YES];
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

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


@end
