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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface videoViewController ()

@property (nonatomic, strong) AVPlayer *avplayer;
@property (strong, nonatomic) IBOutlet UIView *movieView;
@property (strong, nonatomic) IBOutlet UIView *gradientView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation videoViewController
@synthesize subTitle, startButton, arrow;
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
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"aValue"]]) {
        //TODO CHANGE THIS IN PRODUCTION!!
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"aValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Action here
        
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:YES];
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
    [[UILabel appearance] setFont:[UIFont fontWithName:@"CoquetteRegular" size:74.0]];
    subTitle.font = [UIFont fontWithName:@"CoquetteRegular" size:16.0];
    
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
    
    [self flashingAnimation:YES forView:arrow];
    
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


@end
