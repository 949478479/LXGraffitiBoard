//
//  LXPaintingView.h
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import UIKit;


@interface LXPaintingView : UIView

/** 线条粗细. */
@property (nonatomic) IBInspectable CGFloat lineWidth;

/** 线条颜色. */
@property (nonatomic) IBInspectable UIColor *lineColor;

/** 画板内容是否为空. */
@property (readonly, nonatomic, getter=isEmpty) BOOL empty;

/** 画板即将开始绘制时的通知 block. */
@property (copy, nonatomic) void (^willBeginDrawingNotify)(LXPaintingView *drawingView);

/** 画板即将结束绘制时的通知 block. */
@property (copy, nonatomic) void (^willEndDrawingNotify)(LXPaintingView *drawingView);


/** 清屏. */
- (void)clear;

/** 返回到上一笔的状态(粗细,颜色,画板内容). */
- (void)back;

/** 保存当前画板内容截图到系统相册. */
- (void)save;

@end