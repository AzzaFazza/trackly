//
//  Task.h
//  
//
//  Created by Adam Fallon on 25/07/2014.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * taskGenre;
@property (nonatomic, retain) NSData * taskImage;
@property (nonatomic, retain) NSString * taskName;
@property (nonatomic, retain) id taskTags;

@end
