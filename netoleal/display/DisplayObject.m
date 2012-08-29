//
//  DisplayObject.m
//  Giraffone
//
//  Created by Neto Leal on 01/02/12.
//  Copyright (c) 2012 Leal. All rights reserved.
//

#import "DisplayObject.h"

@implementation DisplayObject

- (CGFloat) x
{
    return self.center.x;
}

- (CGFloat) y
{
    return self.center.y;
}

- (void) setX:(CGFloat)x
{
    self.center = CGPointMake( x, self.y );
}

- (void) setY:(CGFloat)y
{
    self.center = CGPointMake( self.x, y );
}

@end
