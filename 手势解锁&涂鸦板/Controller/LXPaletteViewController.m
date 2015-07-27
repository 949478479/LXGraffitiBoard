//
//  LXPaletteViewController.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/8.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXPaletteViewController.h"
#import "LXColorAdjuster.h"


@interface LXPaletteViewController ()

/** 颜色调节器. */
@property (nonatomic, strong) IBOutlet LXColorAdjuster *colorSelector;

@end


@implementation LXPaletteViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.changeColorDidComplete) {
        self.changeColorDidComplete(self.colorSelector.paletteColor);
    }
}

@end