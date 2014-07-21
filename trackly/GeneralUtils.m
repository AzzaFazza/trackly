//
//  GeneralUtils.m
//  EvolveMobile
//
//  Created by Karol Buczel on 05/04/2012.
//  Copyright (c) 2012 Kainos Software Ltd. All rights reserved.
//

#import "GeneralUtils.h"

@implementation GeneralUtils

+ (BOOL)isEmpty:(id)thing {
    return thing == nil ||
    ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
    ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0);
}

+ (BOOL)isntEmpty:(id)thing {
    return ![self isEmpty:thing];
}

+ (NSArray*)valuesFromDictArray:(NSArray*)objects ForKey:(NSString*)key {
    
    NSMutableSet * values = [NSMutableSet set];
    
    for (int i = 0 ; i < [objects count]; i++) {
        
        @try {
            [values addObject:[[objects objectAtIndex:i] valueForKey:key]];
        }
        @catch (NSException * e) {
            NSLog(@"GeneralUtils:valuesFromObjects - Exception at index %i: %@",i,e);
        }
    }
    
    return [[values allObjects]sortedArrayUsingSelector:@selector(compare:)];
}


+ (int)processSearchTypeWithSearchPhrase:(NSString *)searchPhrase {
    //Assuming demo/standalone formats will remain the same, we can determine what the user is searching for e.g. hospNo, NHS No, Name etc.
    NSString *regExpPattern;
    NSRegularExpression *expression;
    int matches;
    
    //Check if searching by hospNo
    regExpPattern = @"^[0-9]{6}$";
    expression = [NSRegularExpression regularExpressionWithPattern:regExpPattern options:0 error:nil];
    matches = [expression numberOfMatchesInString:searchPhrase options:NSMatchingAnchored range:NSMakeRange(0, [searchPhrase length])];
    
    if (matches == 1) {
        return SearchPhraseHospNo;
    }
    
    //Check if searching by NHSNo
    regExpPattern = @"^([0-9]{3}\\s*){2}[0-9]{4}";
    expression = [NSRegularExpression regularExpressionWithPattern:regExpPattern options:0 error:nil];
    matches = [expression numberOfMatchesInString:searchPhrase options:0 range:NSMakeRange(0, [searchPhrase length])];
    
    if (matches == 1) {
        return SearchPhraseNHSNo;
    }
    
    //If nothing else, attempt search by name
    return SearchPhraseName;
}

@end
