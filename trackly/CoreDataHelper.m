//
//  CoreDataHelper
//
//  Created by Luke McNeice on 10/06/2013.
//  Copyright (c) 2013 Kainos Software. All rights reserved.
//

#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "AppStorage.h"

NSString *const EMStoreAndModelName = @"Taskly";

@implementation CoreDataHelper {
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@synthesize mainManagedObjectContext = _mainManagedObjectContext;

#pragma mark - init

- (id)init {
    self = [super init];
    if (self) {
        if (!EMStoreAndModelName) {
            @throw [[NSException alloc] initWithName:@"Const Needs Set" reason:@"Store or Model name can't be nil" userInfo:nil];
        }
        
        // Setup main MOM and PSC.
        [self persistentStoreCoordinator];
        // Setup Main MOC.
        [self mainManagedObjectContext];
        
        if (![self contexthasEntities:_mainManagedObjectContext]) {
            @throw [[NSException alloc] initWithName:@"Context Failed to import Entities" reason:@"No Entities!?" userInfo:nil];
        }
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _mainManagedObjectContext = nil;
}


#pragma mark - Main NSManagedObjectContext setup
+ (NSManagedObjectContext *)mainManagedObjectContext {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *mainMoc = [delegate.appStorage.coreDataHelper mainManagedObjectContext];
    
    return mainMoc;
}

// Returns a new BackgroundManagedObjectContext for the application.
// If the context doesn't already exist, it is created
- (NSManagedObjectContext *)mainManagedObjectContext {
    
    if(_mainManagedObjectContext) {
        return _mainManagedObjectContext;
    }
    
    // create main  MOC
    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainManagedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    
    //Set merge policy
    [_mainManagedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    [_mainManagedObjectContext setUndoManager:nil];//Might want to change this - Filter creation is a good use case for undo
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkAndThrowForThreadSaftey:)
                                                 name:NSManagedObjectContextWillSaveNotification
                                               object:_mainManagedObjectContext];
    
    return _mainManagedObjectContext;
}

#pragma mark - Background ManagedObjectContext

+ (BackgroundManagedObjectContext *)newBackgroundManagedObjectContext {
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    BackgroundManagedObjectContext *bgMoc = [delegate.appStorage.coreDataHelper newBackgroundContext];
    
    return bgMoc;
}

// Returns a new BackgroundManagedObjectContext for the application.
- (BackgroundManagedObjectContext *)newBackgroundContext {
    
    BackgroundManagedObjectContext *backgroundMOC = [BackgroundManagedObjectContext new];
    backgroundMOC.persistentStoreCoordinator = _persistentStoreCoordinator;
    
    //Set merge policy
    [backgroundMOC setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    //Seting up merging event when the MOC saves
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    [[NSNotificationCenter defaultCenter] addObserver:_mainManagedObjectContext
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:backgroundMOC];
    #pragma clang diagnostic pop
    return backgroundMOC;
}

#pragma mark - NSManagedObjectContext control methods
+ (BOOL)contexthasEntities:(NSManagedObjectContext *)ctx {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return [delegate.appStorage.coreDataHelper contexthasEntities:ctx];
}

- (BOOL)contexthasEntities:(NSManagedObjectContext *)ctx {
    NSArray *ents = [ctx.persistentStoreCoordinator.managedObjectModel entities];
    return [ents count] > 0;
}

#pragma mark - Support Fundamentals

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSArray *bundles = @[[NSBundle bundleForClass:[self class]]];
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:bundles];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", EMStoreAndModelName, @"sqlite"]];
    
    NSURL *storeURL = [NSURL fileURLWithPath: storePath];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSPersistentStoreCoordinator *persistentStoreCoordinator = _persistentStoreCoordinator;
        NSDictionary *options = @{
            NSMigratePersistentStoresAutomaticallyOption: @YES,
            NSInferMappingModelAutomaticallyOption: @YES
        };
        
        NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                                      configuration:nil URL:storeURL
                                                                                            options:options error:&error];
        if (!persistentStore) {
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
            [self resetManagedObjectContext:YES];
        }
    }
    
    if ([self supportsFileProtection]) {
        NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
        if (![[NSFileManager defaultManager] setAttributes:fileAttributes ofItemAtPath:storePath error:&error]) {
            @throw [[NSException alloc] initWithName:@"Database encryption exception" reason:[NSString stringWithFormat:@"Error encrypting database: %@",error] userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
        }
    } else {
        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
        @throw [[NSException alloc] initWithName:@"NoFileProtectionSupport" reason:@"Taskly requires File Protection" userInfo:[NSDictionary dictionaryWithObject:systemVersion forKey:@"systemVersion"]];
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Perform blocks convenience methods
+ (void)performBlockAndWaitOnMainContext:(CoreDataMainContextBlock)block {
    if (block) {
        NSManagedObjectContext *mainContext = [self mainManagedObjectContext];
        [mainContext performBlockAndWait:^{
            block(mainContext);
        }];
    }
}

+ (void)performBlockOnMainContext:(CoreDataMainContextBlock)block {
    if (block) {
        NSManagedObjectContext *mainContext = [self mainManagedObjectContext];
        [mainContext performBlock:^{
            block(mainContext);
        }];
    }
}

+ (void)performBlockWithBackgroundContext:(CoreDataConcurrentSaveBlock)block {
    [self performBlockWithBackgroundContext:block withCompletionBlock:nil];
}

+ (void)performBlockWithBackgroundContext:(CoreDataConcurrentSaveBlock)block withCompletionBlock:(CoreDataSaveCompletionBlock)completionBlock {
    
    if (block) {
        NSManagedObjectContext *backgroundContext = [self newBackgroundManagedObjectContext];
        [backgroundContext performBlockAndWait:^{
            [[NSThread currentThread] setName:@"CoreData Background Context Worker"];
            block(backgroundContext);
            
            if (completionBlock) {
                completionBlock();
            }
        }];
    } else {
        @throw [[NSException alloc] initWithName:@"saveDataInBackground: Bad arguments" reason:@"CoreDataConcurrentSaveBlock Block is required. Silly Developer points++" userInfo:nil];
    }
}

#pragma mark - Reset

// Resets the main MOC and optionaly PSC
+ (void)resetManagedObjectContext:(BOOL)resetPersistentStoreCoordinator {
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CoreDataHelper *cdstack = delegate.appStorage.coreDataHelper;
    [cdstack resetManagedObjectContext:resetPersistentStoreCoordinator];
}

// Resets the main MOC and optionaly PSC
- (void)resetManagedObjectContext:(BOOL)resetPersistentStoreCoordinator {
    _mainManagedObjectContext = nil;
    
    if (resetPersistentStoreCoordinator) {
        _persistentStoreCoordinator = nil;
    }
}

+ (void)nuke {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CoreDataHelper *cdstack = delegate.appStorage.coreDataHelper;
    [cdstack nuke];
}

// removes the database and rebuilds a new one
- (void)nuke {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // Remove notifications for thread checking (containing a ref to the main context)
    [[NSNotificationCenter defaultCenter] removeObserver:_mainManagedObjectContext]; // Remove notifications for merging (from background contexts)
    
    NSString *storePath = [[self applicationDocumentsDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",EMStoreAndModelName,@"sqlite"]];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    
    [self resetManagedObjectContext:YES];
    
    // Setup main MOM and PSC
    [self persistentStoreCoordinator];
    // Setup Main MOC
    [self mainManagedObjectContext];
    
    [self cleanUserDefaults];
}

// removes custom settings from UserDefaults
- (void)cleanUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"OfflineModeFilters"];
    [defaults removeObjectForKey:@"ClientConfigKeyDefaultPatientView"];
}

#pragma mark - Safety

//Method used to check if a developer is trying to save on main from a background thread
- (void)checkAndThrowForThreadSaftey:(NSNotification *)notification {
    
    if (![NSThread isMainThread]) {
        @throw [NSException exceptionWithName:@"CoreDataThreadSaveException" reason:@"Core data saves can not cross contexts, you have called saveOnMain from a background thread!" userInfo:[NSDictionary dictionaryWithObject:[NSThread currentThread] forKey:@"currentThread"]];
    }
}

#pragma mark - Convenience Methods

- (NSString *)applicationDocumentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

#pragma mark - Utility Methods
- (BOOL)isExternalBuild {
    NSString *externalFlag = [[[NSProcessInfo processInfo] environment] valueForKey:@"EXTERNAL_BUILD"];
    return (externalFlag != nil && ([externalFlag rangeOfString:@"1"].location != NSNotFound));
}

- (BOOL)supportsFileProtection {
    static BOOL didCheckIfOnOS4 = NO;
    static BOOL runningOnOS4OrBetter = NO;
    
    if(!didCheckIfOnOS4) {
        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
        NSInteger majorSysVer = 3;
        
        if(systemVersion != nil && [systemVersion length] > 0) {
            NSString *fc = [systemVersion substringToIndex:1];
            majorSysVer = [fc integerValue];
        }
        
        runningOnOS4OrBetter = (majorSysVer>=4);
        didCheckIfOnOS4 = YES;
        
    }
    
    return runningOnOS4OrBetter;
}

@end
