//
//  AppStorage.m
//
//  Created by Luke McNeice on 10/06/2013.
//  Copyright (c) 2013 Kainos Software. All rights reserved.
//

#import "AppStorage.h"
#import "CoreDataHelper.h"

@implementation AppStorage
@synthesize coreDataHelper = _coreDataHelper;

- (id)init {
    self = [super init];
    if (self) {
        [self setupCoreDataHelper];
    }
    
    return self;
}

- (void)setupCoreDataHelper {
    _coreDataHelper = [[CoreDataHelper alloc] init];
}

@end
