//
//  LXRectangleBrush.h
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXBaseBrush.h"


@interface LXRectangleBrush : LXBaseBrush

/** 获取用于椭圆/矩形绘制的矩形范围. */
@property (nonatomic, readonly) CGRect rectToDraw;

@end