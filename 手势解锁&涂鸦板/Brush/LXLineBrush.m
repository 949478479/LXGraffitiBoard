//
//  LXLineBrush.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXLineBrush.h"

@implementation LXLineBrush

- (void)configureContext:(CGContextRef)context
{
    [super configureContext:context];

    // 直线工具在基类的基础上将 初始点 和 当前点连线即可.
    CGContextMoveToPoint(context, self.startPoint.x, self.startPoint.y);
    CGContextAddLineToPoint(context, self.currentPoint.x, self.currentPoint.y);
}

@end