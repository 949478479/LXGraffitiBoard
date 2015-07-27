//
//  LXPaintBrush.h
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import UIKit;


@protocol LXPaintBrush <NSObject>

/** 线条粗细. */
@property (nonatomic) CGFloat lineWidth;

/** 线条颜色. */
@property (nonatomic, strong) UIColor *lineColor;

/** 需要重绘的矩形范围. */
@property (nonatomic, readonly) CGRect redrawRect;

/** 是否需要绘制. */
@property (nonatomic, readonly) BOOL needsDraw;


/** 绘制图案到上下文. */
- (void)drawInContext:(CGContextRef)context;

/** 从指定点开始. */
- (void)beginAtPoint:(CGPoint)point;

/** 移动到指定点. */
- (void)moveToPoint:(CGPoint)point;

/** 移动结束. */
- (void)end;

@end