//
//  LXSquareBrush.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/9.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXSquareBrush.h"

@implementation LXSquareBrush

- (void)drawInContext:(CGContextRef)context
{
    [self configureContext:context];

    // 由于继承自圆类,原点会自动调整的,直接画矩形即可.
    CGContextStrokeRect(context, self.rectToDraw);
}

@end