//
//  Task.h
//  Taskly
//
//  Created by Adam Fallon on 20/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSManagedObject

@property (nonatomic, retain) NSString  * taskName;
@property (nonatomic, retain) NSArray   * taskTags;

+(void) addTask: (Task*)tempTask;
+(void) addTimeToTask: (NSDate*)date;
+(NSMutableArray*)getAll;
+(NSMutableArray*)getTaskByTag : (NSString*)tagToSearch;

@end
