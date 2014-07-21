//
//  GeneralUtils.h
//  EvolveMobile
//
//  Created by Karol Buczel on 05/04/2012.
//  Copyright (c) 2012 Kainos Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

enum PatientSearchPhraseType {
    SearchPhraseHospNo,
    SearchPhraseNHSNo,
    SearchPhraseName
};

@interface GeneralUtils : NSObject

+ (BOOL)isEmpty:(id)thing;
+ (BOOL)isntEmpty:(id)thing;

+ (BOOL)internetConnectionEstablished;
+ (NSString *)newUUID;

/**
 * Returns an array of values for the given key from each (JSON) Dict in the input array
 *
 * @param NSArray of JSON NSdictionarys
 * @param NSString key used to get each value
 *
 * @return Main NSManagedObjectContext
 */
+ (NSArray*)valuesFromDictArray:(NSArray*)objects ForKey:(NSString*)key;

/**
 * Process a search in array for a string.
 *
 * @param NSString search key
 * @param NSArray with elements to search on.
 *
 * @return BOOL isStringInArray
 */
+ (BOOL)isString:(NSString *)string inArray:(NSArray *)array;

/*
 * Processes a search phrase and determines what the user is trying to search for
 */
+ (int)processSearchTypeWithSearchPhrase:(NSString *)searchPhrase;
/*
 * Passes in a string to be pluralised or singular, e.g. patient(s)
 */
+ (NSString *)pluralizeString:(NSString *)string withCount:(int)count;

/*
 * Passes in a string to be converted to a NSNumber.
 */
+ (NSNumber *)numberFromString:(NSString *)string;
@end
