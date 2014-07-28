//
//  customTableViewCell.h
//  Taskly
//
//  Created by Adam Fallon on 22/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JBKenBurnsView/JBKenBurnsView.h>

@interface customTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIView *tagsView;
@property (retain, nonatomic) IBOutlet UIView *taskNameView;
@property (retain, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *tagsLabel;
@property (retain, nonatomic) IBOutlet UILabel *taskGenre;
@property (weak, nonatomic) IBOutlet   UIView *cellView;
@property (weak, nonatomic) IBOutlet   UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet   JBKenBurnsView *movingImages;


@end
