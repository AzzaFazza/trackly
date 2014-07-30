//
//  ViewController.h
//  VideoCover
//
//  Created by Bi Chen Ka Kit on 2/6/14.
//  Copyright (c) 2014年 biworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EAIntroView/EAIntroView.h>
#import <FlatUIKit/FlatUIKit.h>
#import <MYBlurIntroductionView/MYBlurIntroductionView.h>

@interface videoViewController : UIViewController<MYIntroductionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet FUIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;

@end
