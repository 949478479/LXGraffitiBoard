//
//  LXRectangleBrush.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXRectangleBrush.h"


@implementation LXRectangleBrush

- (void)drawInContext:(CGContextRef)context
{
    [self configureContext:context];

    // 这里选择重写此方法自己画,因为在 configureContext 中添加路径的话会影响子类.
    CGContextStrokeRect(context, self.rectToDraw);
}

- (CGRect)rectToDraw
{
    return (CGRect) {
        MIN(self.startPoint.x,  self.currentPoint.x),
        MIN(self.startPoint.y,  self.currentPoint.y),
        ABS(self.startPoint.x - self.currentPoint.x),
        ABS(self.startPoint.y - self.currentPoint.y),
    };
}

@end