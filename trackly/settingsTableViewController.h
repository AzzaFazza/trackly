//
//  settingsTableViewController.h
//  Taskly
//
//  Created by Adam Fallon on 30/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface settingsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) IBOutlet UITableView * settingsTableView;
@end
