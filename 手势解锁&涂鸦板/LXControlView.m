//
//  LXControlView.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXControlView.h"
#import "LXPaintingView.h"

@interface LXControlView () <UIBarPositioningDelegate>

/** 涂鸦板. */
@property (weak, nonatomic) IBOutlet LXPaintingView *paintingView;

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

/** 颜色按钮. */
@property (nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end


@implementation LXControlView

#pragma mark 初始化

- (void)awakeFromNib
{
    [super awakeFromNib];

    for (UIButton *button in _buttons) {
        button.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

- (void)setDrawView:(LXPaintingView *)paintingView
{
    _paintingView = paintingView;

    // 这里捕获一下也没啥危害.
    paintingView.willEndDrawingNotify = ^(LXPaintingView *drawView){
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
    _paintingView.lineWidth = sender.value;
}

/** 设置线条颜色. */
- (IBAction)selectLineColor:(UIButton *)sender
{
    sender.enabled = NO;
    sender.layer.borderWidth = 3;

    _selectedColorButton.enabled = YES;
    _selectedColorButton.layer.borderWidth = 0;
    _selectedColorButton = sender;

    _paintingView.lineColor = sender.backgroundColor;
}

/** 清屏. */
- (IBAction)clearAction:(UIButton *)sender
{
    _saveButton.enabled = NO;
    _backButton.enabled = NO;
    _clearButton.enabled = NO;
    
    [_paintingView clear];
}

/** 退回上一步的线条. */
- (IBAction)backAction:(UIButton *)sender
{
    [_paintingView back];

    BOOL enabled = !_paintingView.isEmpty;
    _backButton.enabled = enabled;
    _saveButton.enabled = enabled;
    _clearButton.enabled = enabled;
}

/** 保存图片到系统相册. */
- (IBAction)saveAction:(UIButton *)sender
{
    sender.enabled = NO;

    [_paintingView save];
}
@end