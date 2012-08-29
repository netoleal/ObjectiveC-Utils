//
//  NSDictionary+Ordered.m
//  SpriteTest
//
//  Created by Neto Leal on 8/27/12.
//  Copyright (c) 2012 Lov. All rights reserved.
//

#import "NSDictionary+Ordered.h"

@interface NSDictionary()
@end

@implementation NSDictionary (Ordered)

- (NSArray *)orderedKeys
{
    NSArray *keys = [self allKeys];
    return [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

@end
