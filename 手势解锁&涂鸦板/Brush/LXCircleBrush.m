//
//  LXCircleBrush.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXCircleBrush.h"


@implementation LXCircleBrush

- (CGRect)rectToDraw
{
    CGRect  rect   = super.rectToDraw;
    CGFloat radius = MIN(ABS(self.startPoint.x - self.currentPoint.x),
                         ABS(self.startPoint.y - self.currentPoint.y));

    rect.size = CGSizeMake(radius, radius);

    CGFloat startX   = self.startPoint.x,   startY   = self.startPoint.y;
    CGFloat currentX = self.currentPoint.x, currentY = self.currentPoint.y;

    // 对原点进行调整,让圆圈始终围绕起点变换大小位置.
    if (currentX < startX) {
        rect.origin.x += startX - currentX - radius;
    }
    if (currentY < startY) {
        rect.origin.y += startY - currentY - radius;
    }

    return rect;
}

- (CGRect)redrawRect
{
    // 调整重绘矩形范围,使之匹配实际的圆形.
    CGRect  rect   = super.redrawRect;
    CGSize  size   = rect.size;
    CGPoint origin = rect.origin;

    CGFloat startX   = self.startPoint.x,   startY   = self.startPoint.y;
    CGFloat currentX = self.currentPoint.x, currentY = self.currentPoint.y;

    if (size.height > size.width) {
        if (currentY < startY) {
            origin.y += size.height - size.width;
        }
        size.height = size.width;
    }

    if (size.width > size.height) {
        if (currentX < startX) {
            origin.x += size.width - size.height;
        }
        size.width = size.height;
    }

    return (CGRect) { origin, size };
}

@end