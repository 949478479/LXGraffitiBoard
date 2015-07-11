//
//  LXDashLineBrush.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXDashLineBrush.h"


@implementation LXDashLineBrush

- (void)configureContext:(CGContextRef)context
{
    [super configureContext:context];

    // 虚线在父类直线的基础上设置虚线性质即可.
    CGFloat lengths[2] = { self.lineWidth, self.lineWidth * 2 };
    CGContextSetLineDash(context, 0, lengths, 2);
}

@end