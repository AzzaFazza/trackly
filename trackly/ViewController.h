//
//  ViewController.h
//  trackly
//
//  Created by Adam Fallon on 18/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CXCardView/CXCardView.h>


@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *trayDisplayButton;
@property (weak, nonatomic) IBOutlet UIButton *addTask;
@property (weak, nonatomic) IBOutlet UIView * mainView;
@property (weak, nonatomic) IBOutlet UIView *noTaskView;
@property (weak, nonatomic) IBOutlet UILabel *sadFace;
@property (weak, nonatomic) IBOutlet UILabel *noTaskLabel;
@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (weak, nonatomic) IBOutlet UIButton * addTaskButton;
@property (weak, nonatomic) IBOutlet UILabel *tasksHeaderLabel;




-(IBAction)showTray:(id)sender;
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
@end
