//
//  NSManagedObjectUpdateWithDictionaryInContext.h
//  EvolveMobile
//
//  Created by Luke McNeice on 25/09/2013.
//  Copyright (c) 2013 Kainos Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSManagedObjectUpdateWithDictionaryInContext <NSObject>
- (void)updateWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext*)moc;
@end
