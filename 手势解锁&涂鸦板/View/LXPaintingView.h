//
//  LXPaintingView.h
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import UIKit;

@protocol LXPaintBrush;


@interface LXPaintingView : UIView

/** 背景照片. */
@property (nonatomic, strong) UIImage *backgroundImage;

/** 画刷. */
@property (nonatomic, strong) id<LXPaintBrush> paintBrush;

/** 能否撤销. */
@property (nonatomic, readonly) BOOL canUndo;

/** 能否恢复. */
@property (nonatomic, readonly) BOOL canRedo;


/** 清屏. */
- (void)clear;

/** 撤销. */
- (void)undo;

/** 恢复. */
- (void)redo;

/** 保存画板内容到系统相册. */
- (void)saveToPhotosAlbum;

@end