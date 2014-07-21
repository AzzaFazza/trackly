//
//  NSManagedObject+CRUD.m
//  EvolveMobile
//
//  Created by Karol Buczel on 19/03/2012.
//  Copyright (c) 2012 Kainos Software Ltd. All rights reserved.
//

#import "NSManagedObject+CRUD.h"
#import "AppDelegate.h"
#import "AppStorage.h"
#import <objc/runtime.h>
#import "GeneralUtils.h"
#import "CoreDataHelper.h"


BOOL const strictThreadUse = YES;

@implementation NSManagedObject(CRUD)

+ (NSString *)entityName {
    NSString *className = [NSString stringWithCString:class_getName([self class]) encoding:NSASCIIStringEncoding];
    NSRange rangeOfManagedObject = [className rangeOfString:@"ManagedObject"];
    
    NSString *entityName = (rangeOfManagedObject.location == NSNotFound) ? className :[className substringToIndex:rangeOfManagedObject.location];
    return entityName;
}

+ (NSManagedObjectContext *)mainContext {
    
//    //THREAD SAFETY
//    if(![[NSThread currentThread] isEqual:[NSThread mainThread]]){
//        NSLog(@"\n\n********************************\nDO NOT ACCESS THE MAIN CONTEXT FROM A BACKGROUND THREAD\n********************************\n\n");
//        @throw [NSException exceptionWithName:@"ManagedObjectContext Thread Containment" reason:@"DO NOT ACCESS THE MAIN CONTEXT FROM A BACKGROUND THREAD" userInfo:nil];
//    }
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return [delegate.appStorage.coreDataHelper mainManagedObjectContext]; //use this line with new core data implemetation
}

+ (id)createObjectInContext:(NSManagedObjectContext *)context {
    
    NSString *className = [self entityName];
    
    __block NSManagedObject *obj;
    
    [context performBlockAndWait:^{
        obj = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:context];
    }];
    
    return obj;
}

+ (id)readOrCreateObjectInContext:(NSManagedObjectContext *)context WithParamterName:(NSString *)parameterName andValue:(id)parameterValue {
    
    NSManagedObject *object;
    
    object = [self readObjectInContext:context withParamterName:parameterName andValue:parameterValue];
    
    if ([GeneralUtils isEmpty:object]) {
        object = [self createObjectInContext:context];
        [object setValue:parameterValue forKey:parameterName];
    }
    
    return object;
}


+ (BOOL)checkModelExistsInContext:(NSManagedObjectContext *)context {
    
    BOOL modelsExist = YES;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:[[self class] entityName] inManagedObjectContext:context]];
    [request setIncludesSubentities:NO];
    
    __block NSUInteger count;
    
    [context performBlockAndWait:^{
        NSError *error;
        count = [context countForFetchRequest:request error:&error];
    }];
    
    if(count == NSNotFound || count == 0) {
        modelsExist = NO;
    }
    
    return modelsExist;
}

+ (NSArray *)readObjectsInContext:(NSManagedObjectContext *)context WithParamterName:(NSString *)parameterName andValueArray:(NSArray *)parameterValues {
    
    NSString *className = [self entityName];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:parameterName ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K IN %@)", parameterName, parameterValues];
    
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.predicate = predicate;
    
    __block NSArray *results;
    
    [context performBlockAndWait:^{
        NSError *error;
        results = [context executeFetchRequest:request error: &error];
    }];
    
    return results;
}

+ (id)readObjectInContext:(NSManagedObjectContext *)context withParamterName:(NSString *)parameterName andValue:(id)parameterValue {
    
    NSString *className = [self entityName];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:parameterName ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", parameterName, parameterValue];
    
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.predicate = predicate;
    
    
    __block NSArray *results;
    
    [context performBlockAndWait:^{
        NSError *error;
        results = [context executeFetchRequest:request error: &error];
    }];
    
    return [results lastObject];
}

+ (NSArray *)readObjectsinContext:(NSManagedObjectContext *)context WithPredicate:(NSPredicate *)pred andSortKey:(NSString *)sortKey {
    
    NSString *className = [self entityName];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES];
    
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.predicate = pred;
    
    __block NSArray *results;
    
    [context performBlockAndWait:^{
        NSError *error;
        results = [context executeFetchRequest:request error: &error];
    }];
    
    
    return results;
}

+ (NSArray *)readAllObjectsInContext:(NSManagedObjectContext *)context {
    
    __block NSArray *results;
    
    [context performBlockAndWait:^(){
        NSError *error;
        
        NSString *className = [self entityName];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
        
        results = [context executeFetchRequest:request error:&error];
        
    }];
    
    return results;
    
}

+ (void)removeAllObjectsInContext:(NSManagedObjectContext *)context {
    
    [context performBlockAndWait:^{
        NSArray *objects = [self readAllObjectsInContext:context];
        
        for (NSManagedObject *obj in objects) {
            [context deleteObject:obj];
        }
        
        NSError *error;
        [context save:&error];
        
    }];
}

+ (void)deleteObject:(NSManagedObject *)object inContext:(NSManagedObjectContext *)context {
    if (object != nil) {
        [context performBlockAndWait:^{
            [context deleteObject:object];
        }];
    }
}

+ (void)deleteObjectsinContext:(NSManagedObjectContext *)context WithPredicate:(NSPredicate *)deletePredicate {
    
    NSString *className = [self entityName];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:className];
    fetchRequest.predicate = deletePredicate;
    
    [context performBlockAndWait:^{
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in results) {
        [context deleteObject:managedObject];
    }
    }];
}

+ (BOOL)saveOnMain {
    
    __block BOOL saveSuccessful = YES;
    
    // TJ: To make long story short:
    // We need to save the main context in block, as usual. For safety, we use performBlockAndWait to do that.
    
    [CoreDataHelper performBlockAndWaitOnMainContext:^(NSManagedObjectContext *mainContext) {
        NSError *error;
        saveSuccessful = [mainContext save:&error];
    }];
    
    return saveSuccessful;
    
}

- (void)updateWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)moc {
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"Effective SIGABT - Abstract method in class (%@) should be overriden",[self class]] reason:@"Method 'updateWithDictionary:context:' not implemented " userInfo:nil];
}


@end