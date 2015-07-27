//
//  LXPaletteViewController.h
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/8.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import UIKit;

@class LXColorAdjuster;


@interface LXPaletteViewController : UIViewController

/** 颜色调节器. */
@property (nonatomic, readonly, strong) LXColorAdjuster *colorSelector;

/** 颜色调节完成后的回调. */
@property (nonatomic, copy) void (^changeColorDidComplete)(UIColor *color);

@end