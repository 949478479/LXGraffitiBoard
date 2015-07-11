//
//  LXArrowBrush.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/7.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXArrowBrush.h"


/** 箭头分叉的长度. */
static const CGFloat kLXRamifyLength = 30;

/** 箭头分叉和直线间的夹角. */
static const CGFloat kLXRamifyAngle = M_PI_4 * 0.5;


@interface LXArrowBrush ()

/** 是否绘制箭头. */
@property (nonatomic) BOOL showArrow;

/** 沿箭头方向看,箭头左分支的端点. */
@property (nonatomic) CGPoint leftRamifyPoint;

/** 沿箭头方向看,箭头右分支的端点. */
@property (nonatomic) CGPoint rightRamifyPoint;

@end


@implementation LXArrowBrush

- (void)beginAtPoint:(CGPoint)point
{
    [super beginAtPoint:point];

    _leftRamifyPoint  = point;
    _rightRamifyPoint = point;
}

- (void)moveToPoint:(CGPoint)point
{
    [super moveToPoint:point];

    // 到起点的距离小于箭头分叉长度1.5倍时不要绘制箭头,否则直线太短就俩分叉好难看.
    CGFloat dx = point.x - self.startPoint.x;
    CGFloat dy = point.y - self.startPoint.y;

    _showArrow = ( (dx * dx + dy * dy) > (2.25 * kLXRamifyLength * kLXRamifyLength) );
}

- (void)end
{
    [super end];

    _showArrow = NO;
}

- (void)configureContext:(CGContextRef)context
{
    [super configureContext:context];

    [self p_calculateRamifyPoint]; // 计算左右两个分叉点.

    CGFloat endX = self.currentPoint.x;
    CGFloat endY = self.currentPoint.y;

    // 画直线.
    CGContextMoveToPoint(context, self.startPoint.x, self.startPoint.y);
    CGContextAddLineToPoint(context, endX, endY);

    // 画左分叉.
    CGContextMoveToPoint(context, endX, endY);
    CGContextAddLineToPoint(context, _leftRamifyPoint.x, _leftRamifyPoint.y);

    // 画右分叉.
    CGContextMoveToPoint(context, endX, endY);
    CGContextAddLineToPoint(context, _rightRamifyPoint.x, _rightRamifyPoint.y);
}

- (void)drawInContext:(CGContextRef)context
{
    if (!_showArrow) return; // 小于显示距离则不显示箭头,如果当前显示了箭头,则箭头会消失,直到达到距离要求.

    [super drawInContext:context];
}

- (CGRect)redrawRect
{
    CGFloat minX = fmin(fmin(fmin(fmin(self.startPoint.x,
                                       self.previousPoint.x),
                                       self.currentPoint.x),
                                       _leftRamifyPoint.x),
                                       _rightRamifyPoint.x) - self.lineWidth / 2;

    CGFloat minY = fmin(fmin(fmin(fmin(self.startPoint.y,
                                       self.previousPoint.y),
                                       self.currentPoint.y),
                                       _leftRamifyPoint.y),
                                       _rightRamifyPoint.y) - self.lineWidth / 2;

    CGFloat maxX = fmax(fmax(fmax(fmax(self.startPoint.x,
                                       self.previousPoint.x),
                                       self.currentPoint.x),
                                       _leftRamifyPoint.x),
                                       _rightRamifyPoint.x) + self.lineWidth / 2;

    CGFloat maxY = fmax(fmax(fmax(fmax(self.startPoint.y,
                                       self.previousPoint.y),
                                       self.currentPoint.y),
                                       _leftRamifyPoint.y),
                                       _rightRamifyPoint.y) + self.lineWidth / 2;

    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

#pragma mark 计算分叉点

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"

- (void)p_calculateRamifyPoint
{
    CGFloat startX = self.startPoint.x, startY = self.startPoint.y;
    CGFloat endX   = self.currentPoint.x, endY = self.currentPoint.y;

    CGFloat dx = endX - startX;
    CGFloat dy = endY - startY;

    CGFloat θ = atan(ABS(dy / dx)); // 箭头分叉与直线的夹角为 θ.

    if (dx > 0 && dy < 0) {      // 第一象限.
        _leftRamifyPoint.x  = endX - kLXRamifyLength * cos(θ - kLXRamifyAngle);
        _leftRamifyPoint.y  = endY + kLXRamifyLength * sin(θ - kLXRamifyAngle);

        _rightRamifyPoint.x = endX - kLXRamifyLength * sin(M_PI_2 - kLXRamifyAngle - θ);
        _rightRamifyPoint.y = endY + kLXRamifyLength * cos(M_PI_2 - kLXRamifyAngle - θ);
    }
    else if (dx < 0 && dy < 0) { // 第二象限.
        _leftRamifyPoint.x  = endX - kLXRamifyLength * sin(θ + kLXRamifyAngle - M_PI_2);
        _leftRamifyPoint.y  = endY + kLXRamifyLength * cos(θ + kLXRamifyAngle - M_PI_2);

        _rightRamifyPoint.x = endX + kLXRamifyLength * cos(θ - kLXRamifyAngle);
        _rightRamifyPoint.y = endY + kLXRamifyLength * sin(θ - kLXRamifyAngle);
    }
    else if (dx < 0 && dy > 0) { // 第三象限.
        _leftRamifyPoint.x  = endX + kLXRamifyLength * cos(θ - kLXRamifyAngle);
        _leftRamifyPoint.y  = endY - kLXRamifyLength * sin(θ - kLXRamifyAngle);

        _rightRamifyPoint.x = endX - kLXRamifyLength * sin(θ + kLXRamifyAngle - M_PI_2);
        _rightRamifyPoint.y = endY - kLXRamifyLength * cos(θ + kLXRamifyAngle - M_PI_2);
    }
    else if (dx > 0 && dy > 0) { // 第四象限.
        _leftRamifyPoint.x  = endX - kLXRamifyLength * cos(θ - kLXRamifyAngle);
        _leftRamifyPoint.y  = endY - kLXRamifyLength * sin(θ - kLXRamifyAngle);

        _rightRamifyPoint.x = endX + kLXRamifyLength * sin(θ + kLXRamifyAngle - M_PI_2);
        _rightRamifyPoint.y = endY - kLXRamifyLength * cos(θ + kLXRamifyAngle - M_PI_2);
    }
    else if (dx > 0 && dy == 0) { // x 正轴.
        _leftRamifyPoint.x  = endX - kLXRamifyLength * cos(kLXRamifyAngle);
        _leftRamifyPoint.y  = endY - kLXRamifyLength * sin(kLXRamifyAngle);

        _rightRamifyPoint.x = _leftRamifyPoint.x;
        _rightRamifyPoint.y = endY + kLXRamifyLength * sin(kLXRamifyAngle);
    }
    else if (dx < 0 && dy == 0) { // x 负轴.
        _leftRamifyPoint.x  = endX + kLXRamifyLength * cos(kLXRamifyAngle);
        _leftRamifyPoint.y  = endY + kLXRamifyLength * sin(kLXRamifyAngle);

        _rightRamifyPoint.x = _leftRamifyPoint.x;
        _rightRamifyPoint.y = endY - kLXRamifyLength * sin(kLXRamifyAngle);
    }
    else if (dx == 0 && dy < 0) { // y 正轴.
        _leftRamifyPoint.x  = endX - kLXRamifyLength * sin(kLXRamifyAngle);
        _leftRamifyPoint.y  = endY + kLXRamifyLength * cos(kLXRamifyAngle);

        _rightRamifyPoint.x = endX + kLXRamifyLength * sin(kLXRamifyAngle);
        _rightRamifyPoint.y = _leftRamifyPoint.y;
    }
    else if (dx == 0 && dy > 0) { // y 负轴.
        _leftRamifyPoint.x  = endX + kLXRamifyLength * sin(kLXRamifyAngle);
        _leftRamifyPoint.y  = endY - kLXRamifyLength * cos(kLXRamifyAngle);

        _rightRamifyPoint.x = endX - kLXRamifyLength * sin(kLXRamifyAngle);
        _rightRamifyPoint.y = _leftRamifyPoint.y;
    }
    else {
        // 原点不用考虑.
    }
}

#pragma clang diagnostic pop

@end