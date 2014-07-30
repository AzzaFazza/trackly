//
//  UIFont+UIFont_SystemFontOverride.m
//  Taskly
//
//  Created by Adam Fallon on 30/07/2014.
//  Copyright (c) 2014 Dot.ly. All rights reserved.
//

#import "UIFont+UIFont_SystemFontOverride.h"

@implementation UIFont (UIFont_SystemFontOverride)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:16];
}

#pragma clang diagnostic pop
@end
