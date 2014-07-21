//
//  NSManagedObject+CRUD.h
//  EvolveMobile
//
//  Created by Karol Buczel on 19/03/2012.
//  Copyright (c) 2012 Kainos Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObjectUpdateWithDictionaryInContext.h"

@interface NSManagedObject(CRUD) <NSManagedObjectUpdateWithDictionaryInContext>

+ (NSString *)entityName;
+ (BOOL)checkModelExistsInContext:(NSManagedObjectContext*)context;

+ (NSManagedObjectContext *)mainContext;

+ (id)createObjectInContext:(NSManagedObjectContext*)context;
+ (id)readOrCreateObjectInContext:(NSManagedObjectContext*)context WithParamterName:(NSString *)parameterName andValue:(id)parameterValue;

+ (id)readObjectInContext:(NSManagedObjectContext *)context withParamterName:(NSString *)parameterName andValue:(id)parameterValue;
+ (NSArray *)readAllObjectsInContext:(NSManagedObjectContext *)moc;
+ (NSArray*)readObjectsInContext:(NSManagedObjectContext*)context WithParamterName:(NSString *)parameterName andValueArray:(NSArray*)parameterValues;
+ (NSArray*)readObjectsinContext:(NSManagedObjectContext *)context WithPredicate:(NSPredicate*)pred andSortKey:(NSString*)sortKey;

+ (void)deleteObject:(NSManagedObject *)object inContext:(NSManagedObjectContext*)moc;
+ (void)removeAllObjectsInContext:(NSManagedObjectContext *)moc;
+ (void)deleteObjectsinContext:(NSManagedObjectContext *)moc WithPredicate:(NSPredicate *)deletePredicate;

+ (BOOL)saveOnMain;

- (void)updateWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext*)moc;

@end