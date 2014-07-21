//
//  BackgroundManagedObjectContext.m
//
//  Created by Luke McNeice on 10/06/2013.
//  Copyright (c) 2013 Kainos Software. All rights reserved.
//

#import "BackgroundManagedObjectContext.h"

@implementation BackgroundManagedObjectContext

- (id)init {
    self = [super initWithConcurrencyType:NSPrivateQueueConcurrencyType];    
    return self;
}

@end
