//
//  LXPaintingLayer.h
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/5.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import UIKit;

@protocol LXPaintBrush;


@interface LXPaintingLayer : CALayer

/** 能否撤销. */
@property (nonatomic, readonly) BOOL canUndo;

/** 能否恢复. */
@property (nonatomic, readonly) BOOL canRedo;

/** 画刷对象. */
@property (nonatomic, strong) id<LXPaintBrush> paintBrush;


/** 触摸事件响应,于四个触摸事件发生时调用此方法并将 UITouch 传入. */
- (void)touchAction:(UITouch *)touch;

/** 清屏. */
- (void)clear; 

/** 撤销. */
- (void)undo;

/** 恢复. */
- (void)redo;

@end