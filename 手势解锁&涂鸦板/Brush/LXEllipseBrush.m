//
//  LXEllipseBrush.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXEllipseBrush.h"

@implementation LXEllipseBrush

- (void)drawInContext:(CGContextRef)context
{
    [self configureContext:context];

    CGContextStrokeEllipseInRect(context, self.rectToDraw);
}

@end