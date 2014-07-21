//
//  CoreDataHelper
//
//  Created by Luke McNeice on 10/06/2013.
//  Copyright (c) 2013 Kainos Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundManagedObjectContext.h"

/** Const used to name the Model and Store */
extern NSString *const EMStoreAndModelName;

typedef void (^CoreDataConcurrentSaveBlock)(NSManagedObjectContext *);
typedef void(^CoreDataSaveCompletionBlock)(void);

typedef void (^CoreDataMainContextBlock)(NSManagedObjectContext *);

/**
 * Used to access the main NSManagedObjectContext and provides concurrent Core Data Conveniance 
 */
@interface CoreDataHelper : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;

/**
 * Returns the Main NSManagedObjectContext
 *
 * @return Main NSManagedObjectContext
 */
+ (NSManagedObjectContext *)mainManagedObjectContext;

/**
 * Returns a new NSManagedObjectContext of NSPrivateQueueConcurrencyType
 *
 * @return BackgroundManagedObjectContext
 */
+ (BackgroundManagedObjectContext *)newBackgroundManagedObjectContext;

/**
 * Convenience method performing a block, injecting a NSManagedObjectContext to be used there.
 *
 * Block is executed on main thread and call block until it's finished.
 *
 * @param block with Core Data calls on main context
 */
+ (void)performBlockAndWaitOnMainContext:(CoreDataMainContextBlock)block;

+ (void)performBlockOnMainContext:(CoreDataMainContextBlock)block;

/**
 * Convenience method performing a block, injecting a NSManagedObjectContext to be used there.
 *
 * Block is executed on background context queue and call doesn't block.
 *
 * @param block with Core Data calls on background context
 * @param completionBlock executed when main block is finished
 */
+ (void)performBlockWithBackgroundContext:(CoreDataConcurrentSaveBlock)block
                      withCompletionBlock:(CoreDataSaveCompletionBlock)completionBlock;

/**
 * Convenience method performing a block, injecting a NSManagedObjectContext to be used there.
 *
 * Block is executed on main thread and call block until it's finished.
 *
 * @param block with Core Data calls on main context
 */
+ (void)performBlockWithBackgroundContext:(CoreDataConcurrentSaveBlock)block;

/**
 * Say goodbye to your database
 */
+ (void)nuke;

+ (BOOL)contexthasEntities:(NSManagedObjectContext*)ctx;

@end
