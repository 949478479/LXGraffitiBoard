//
//  LXEraserBrush.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXEraserBrush.h"

@implementation LXEraserBrush

- (void)configureContext:(CGContextRef)context
{
    [super configureContext:context];

    // 橡皮只要在父类普通画笔的基础上将混合模式由默认的 normal 改为 clear 即可.
    CGContextSetBlendMode(context, kCGBlendModeClear);
}

@end