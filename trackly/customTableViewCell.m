//
//  customTableViewCell.m
//  Taskly
//
//  Created by Adam Fallon on 22/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import "customTableViewCell.h"

@implementation customTableViewCell
@synthesize tagsView, taskNameView, imageView, taskNameLabel, tagsLabel, taskGenre, cellView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        taskNameView = [[UIView alloc]init];
        tagsView = [[UIView alloc]init];
        imageView = [[UIImageView alloc]init];
        taskNameLabel = [[UILabel alloc]init];
        tagsLabel = [[UILabel alloc]init];
        taskGenre = [[UILabel alloc]init];
        cellView = [[UIView alloc]init];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
