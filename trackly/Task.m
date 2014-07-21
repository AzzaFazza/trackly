//
//  Task.m
//  Taskly
//
//  Created by Adam Fallon on 20/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import "Task.h"

@implementation Task
@dynamic taskTags, taskName;
static NSMutableArray * allTasks;

+(void)addTask:(Task *)tempTask {
    if([allTasks count] == 0) {
        allTasks = [[NSMutableArray alloc]init];
        
    }
    
    [allTasks addObject:tempTask];
    
}

+(NSMutableArray*)getAll {
    return allTasks;
}

+(NSMutableArray*)getTaskByTag:(NSString *)tagToSearch {
    NSMutableArray * foundTasksWithTag = [[NSMutableArray alloc]init];
    Task * tempTask;
    for (int temp = 0; temp >= allTasks.count; temp++) {
        if([tempTask.taskTags containsObject:tagToSearch]) {
            NSLog(@"GREAT SUCESS");
            tempTask.taskName = [NSString stringWithFormat:@"%i", temp];
            [foundTasksWithTag addObject:tempTask];
        } else {
            return nil;
            NSLog(@"No Object by that tag found");
        }
    }
            return foundTasksWithTag;
}

@end
