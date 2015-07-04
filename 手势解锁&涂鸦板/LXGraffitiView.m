//
//  LXGraffitiView.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXGraffitiView.h"
#import "LXDrawingView.h"

@interface LXGraffitiView () <UIBarPositioningDelegate>

/** 涂鸦板. */
@property (weak, nonatomic) IBOutlet LXDrawingView *drawView;

/** 清屏按钮. */
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

/** 回退按钮. */
@property (weak, nonatomic) IBOutlet UIButton *backButton;

/** 保存按钮. */
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

/** 线条宽度滑块. */
@property (weak, nonatomic) IBOutlet UISlider *lineWidthSlider;

/** 上次选中的按钮. */
@property (weak, nonatomic) IBOutlet UIButton *selectedColorButton;

@end


@implementation LXGraffitiView

- (void)setDrawView:(LXDrawingView *)drawView
{
    _drawView = drawView;

    // 这里捕获一下也没啥危害.
    drawView.willEndDrawingNotify = ^(LXDrawingView *drawView){
        _saveButton.enabled = YES;
        _backButton.enabled = YES;
        _clearButton.enabled = YES;
    };
}

#pragma mark UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached; // 调整导航栏紧贴屏幕顶部.
}

#pragma mark UI事件处理

/** 设置线条宽度. */
- (IBAction)lineWidthChanged:(UISlider *)sender
{
    _drawView.lineWidth = sender.value;
}

/** 设置线条颜色. */
- (IBAction)selectLineColor:(UIButton *)sender
{
    sender.enabled = NO;
    sender.layer.cornerRadius = 0;

    _selectedColorButton.enabled = YES;
    _selectedColorButton.layer.cornerRadius = CGRectGetWidth(_selectedColorButton.bounds) / 2;
    _selectedColorButton = sender;

    _drawView.lineColor = sender.backgroundColor;
}

/** 清屏. */
- (IBAction)clearAction:(UIButton *)sender
{
    _saveButton.enabled = NO;
    _backButton.enabled = NO;
    _clearButton.enabled = NO;
    
    [_drawView clear];
}

/** 退回上一步的线条. */
- (IBAction)backAction:(UIButton *)sender
{
    [_drawView back];

    BOOL enabled = !_drawView.isEmpty;
    _backButton.enabled = enabled;
    _saveButton.enabled = enabled;
    _clearButton.enabled = enabled;
}

/** 保存图片到系统相册. */
- (IBAction)saveAction:(UIButton *)sender
{
    sender.enabled = NO;

    [_drawView save];
}
@end