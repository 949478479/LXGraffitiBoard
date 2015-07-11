//
//  LXPencilBrush.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXPencilBrush.h"


@interface LXPencilBrush ()

/** 绘图路径. */
@property (nonatomic) CGMutablePathRef path;

@end


@implementation LXPencilBrush

// 普通画笔相对基类有些特殊,这里重写了几个属性,初始点干脆用不到.
// needsDraw 需要根据两次移动间距决定,相应的 previousPoint 和 currentPoint 也并不是每次移动都一定刷新值.
@synthesize currentPoint  = _currentPoint;
@synthesize previousPoint = _previousPoint;
@synthesize needsDraw     = _needsDraw;

- (void)beginAtPoint:(CGPoint)point
{
    _needsDraw     = YES;
    _previousPoint = point;
    _currentPoint  = point;

    // 普通画笔比较特殊,要保证之前的每一个移动点都在,因此需要一条路径.
    _path = CGPathCreateMutable();

    CGPathMoveToPoint   (_path, NULL, point.x, point.y);
    CGPathAddLineToPoint(_path, NULL, point.x, point.y); // 为了点下去就能画一个点.
}

- (void)moveToPoint:(CGPoint)point
{
    // 移动距离小于笔画宽度一半,基本看不出来,没必要重绘.
    CGFloat dx = point.x - _currentPoint.x;
    CGFloat dy = point.y - _currentPoint.y;
    if ( (dx * dx + dy * dy) < (self.lineWidth * self.lineWidth / 4) ) {
        _needsDraw = NO;
        return;
    }

    _needsDraw     = YES;
    _previousPoint = _currentPoint;
    _currentPoint  = point;

    CGPathAddLineToPoint(_path, NULL, point.x, point.y);
}

- (void)end
{
    CGPathRelease(_path);
    _path      = NULL;
    _needsDraw = NO;
}

- (void)configureContext:(CGContextRef)context
{
    [super configureContext:context];

    // 普通画笔工具在基类的基础上添加自己自定义的路径即可.
    CGContextAddPath(context, _path);
}

- (CGRect)redrawRect
{
    // 普通画笔和画矩形之类的不一样.每次重绘当前点和上一点之间的小矩形即可,没必要包含起点.
    CGFloat minX = fmin(_currentPoint.x, _previousPoint.x) - self.lineWidth / 2;
    CGFloat minY = fmin(_currentPoint.y, _previousPoint.y) - self.lineWidth / 2;
    CGFloat maxX = fmax(_currentPoint.x, _previousPoint.x) + self.lineWidth / 2;
    CGFloat maxY = fmax(_currentPoint.y, _previousPoint.y) + self.lineWidth / 2;

    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

@end