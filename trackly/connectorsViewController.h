//
//  connectorsViewController.h
//  Taskly
//
//  Created by Adam Fallon on 24/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>

@interface connectorsViewController : UIViewController
@property (weak, nonatomic) IBOutlet FUIButton *Exchange;
@property (weak, nonatomic) IBOutlet FUIButton *Asana;
@property (weak, nonatomic) IBOutlet FUIButton *GoogleCalender;
@property (weak, nonatomic) IBOutlet FUIButton *Evernote;
@property (weak, nonatomic) IBOutlet FUIButton *GitHub;
@property (weak, nonatomic) IBOutlet FUIButton *Trello;

@end
