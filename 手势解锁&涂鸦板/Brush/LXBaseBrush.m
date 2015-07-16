//
//  LXBaseBrush.h
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXBaseBrush.h"
#import "LXLineBrush.h"
#import "LXArrowBrush.h"
#import "LXPencilBrush.h"
#import "LXEraserBrush.h"
#import "LXCircleBrush.h"
#import "LXSquareBrush.h"
#import "LXEllipseBrush.h"
#import "LXDashLineBrush.h"
#import "LXRectangleBrush.h"


@implementation LXBaseBrush

+ (id<LXPaintBrush>)brushWithType:(LXBrushType)brushType
{
    switch (brushType) {
        case LXBrushTypePencil:
            return [LXPencilBrush new];

        case LXBrushTypeEraser:
            return [LXEraserBrush new];

        case LXBrushTypeLine:
            return [LXLineBrush new];

        case LXBrushTypeDashLine:
            return [LXDashLineBrush new];

        case LXBrushTypeRectangle:
            return [LXRectangleBrush new];

        case LXBrushTypeSquare:
            return [LXSquareBrush new];

        case LXBrushTypeEllipse:
            return [LXEllipseBrush new];

        case LXBrushTypeCircle:
            return [LXCircleBrush new];

        case LXBrushTypeArrow:
            return [LXArrowBrush new];
    }
    return nil;
}

#pragma mark - LXPaintBrush 协议方法

- (void)beginAtPoint:(CGPoint)point
{
    _startPoint    = point;
    _currentPoint  = point;
    _previousPoint = point;
    _needsDraw     = YES;
}

- (void)moveToPoint:(CGPoint)point
{
    _previousPoint = _currentPoint;
    _currentPoint  = point;
}

- (void)end
{
    _needsDraw = NO;
}

- (void)drawInContext:(CGContextRef)context
{
    [self configureContext:context];

    CGContextStrokePath(context);
}

- (CGRect)redrawRect
{
    // 根据 起点, 上一点, 当前点 三点计算包含三点的最小重绘矩形.适用于画矩形,椭圆之类的图案.
    CGFloat minX = fmin(fmin(_startPoint.x, _previousPoint.x), _currentPoint.x) - _lineWidth / 2;
    CGFloat minY = fmin(fmin(_startPoint.y, _previousPoint.y), _currentPoint.y) - _lineWidth / 2;
    CGFloat maxX = fmax(fmax(_startPoint.x, _previousPoint.x), _currentPoint.x) + _lineWidth / 2;
    CGFloat maxY = fmax(fmax(_startPoint.y, _previousPoint.y), _currentPoint.y) + _lineWidth / 2;

    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

#pragma mark - 配置上下文

- (void)configureContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
}

@end