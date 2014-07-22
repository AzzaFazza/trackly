//
//  Task.h
//  Taskly
//
//  Created by Adam Fallon on 22/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * taskName;
@property (nonatomic, retain) id taskTags;
@property (nonatomic, retain) NSString * taskGenre;

@end
