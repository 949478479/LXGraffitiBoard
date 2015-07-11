//
//  LXPaintViewController.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/8.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXColorAdjuster.h"
#import "LXPaintControlView.h"
#import "LXPaintViewController.h"
#import "LXPaletteViewController.h"


@interface LXPaintViewController ()

/** 涂鸦控制面板. */
@property (nonatomic) IBOutlet LXPaintControlView *contorlView;

@end


@implementation LXPaintViewController

#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PopoverPaletteVC"]) {
    
        LXPaletteViewController *paletteVC   = segue.destinationViewController;
        paletteVC.colorSelector.paletteColor = _contorlView.selectedColor;
        paletteVC.changeColorDidComplete     = ^(UIColor *color) {
            _contorlView.selectedColor = color;
        };
    }
}

@end