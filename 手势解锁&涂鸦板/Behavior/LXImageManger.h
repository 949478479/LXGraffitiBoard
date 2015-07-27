//
//  LXImageManger.h
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/9.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import UIKit;


@interface LXImageManger : NSObject

/** 获取图片管理者. */
+ (instancetype)sharedImageManger;

/** 添加图片. */
- (void)addImage:(UIImage *)image;

/** 是否可以撤销. */
- (BOOL)canUndo;

/** 获取撤销操作的图片. */
- (UIImage *)imageForUndo;

/** 是否可以恢复. */
- (BOOL)canRedo;

/** 获取恢复操作的图片. */
- (UIImage *)imageForRedo;

/** 移除所有图片. */
- (void)removeAllImages;

@end