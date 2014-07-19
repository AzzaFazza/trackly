//
//  ViewController.h
//  VideoCover
//
//  Created by Bi Chen Ka Kit on 2/6/14.
//  Copyright (c) 2014年 biworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTTTJazzHands.h"

@interface videoViewController : UIViewController <IFTTTAnimatedScrollViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *subTitle;

@end
