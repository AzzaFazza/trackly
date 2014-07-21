//
//  AppStorage.h
//
//  Created by Luke McNeice on 10/06/2013.
//  Copyright (c) 2013 Kainos Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CoreDataHelper;

@interface AppStorage : NSObject
@property (nonatomic,strong) CoreDataHelper * coreDataHelper;
@end
