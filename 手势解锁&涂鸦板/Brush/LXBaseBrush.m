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


@interface LXBaseBrush ()

/** 是否需要绘制. */
@property (nonatomic, readwrite) BOOL needsDraw;

/** 初始点. */
@property (nonatomic, readwrite) CGPoint startPoint;

/** 上一点. */
@property (nonatomic, readwrite) CGPoint previousPoint;

/** 当前点. */
@property (nonatomic, readwrite) CGPoint currentPoint;

@end


@implementation LXBaseBrush
@synthesize lineWidth = _lineWidth, lineColor = _lineColor;

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
    self.startPoint    = point;
    self.currentPoint  = point;
    self.previousPoint = point;
    self.needsDraw     = YES;
}

- (void)moveToPoint:(CGPoint)point
{
    self.previousPoint = self.currentPoint;
    self.currentPoint  = point;
}

- (void)end
{
    self.needsDraw = NO;
}

- (void)drawInContext:(CGContextRef)context
{
    [self configureContext:context];

    CGContextStrokePath(context);
}

- (CGRect)redrawRect
{
    // 根据 起点, 上一点, 当前点 三点计算包含三点的最小重绘矩形.适用于画矩形,椭圆之类的图案.
    CGFloat minX = fmin(fmin(self.startPoint.x, self.previousPoint.x), self.currentPoint.x) - self.lineWidth / 2;
    CGFloat minY = fmin(fmin(self.startPoint.y, self.previousPoint.y), self.currentPoint.y) - self.lineWidth / 2;
    CGFloat maxX = fmax(fmax(self.startPoint.x, self.previousPoint.x), self.currentPoint.x) + self.lineWidth / 2;
    CGFloat maxY = fmax(fmax(self.startPoint.y, self.previousPoint.y), self.currentPoint.y) + self.lineWidth / 2;

    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

#pragma mark - 配置上下文

- (void)configureContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
}

@end