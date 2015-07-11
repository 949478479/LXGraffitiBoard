//
//  LXColorAdjuster.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXColorAdjuster.h"


/** 颜色滑块的 tag. */
typedef NS_ENUM(NSUInteger, LXColor){
    /** 红颜色滑块. */
    LXColorRed,
    /** 绿颜色滑块. */
    LXColorGreen,
    /** 蓝颜色滑块. */
    LXColorBlue,
    /** 透明度滑块. */
    LXColorAlpha,
};


@interface LXColorAdjuster ()

/** 预览窗. */
@property (nonatomic) IBOutlet UIView *previewView;

/** 各种颜色值. */
@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat green;
@property (nonatomic) CGFloat blue;
@property (nonatomic) CGFloat alpha;

/** 各种颜色值标签. */
@property (nonatomic) IBOutlet UILabel *redValueLabel;
@property (nonatomic) IBOutlet UILabel *greenValueLabel;
@property (nonatomic) IBOutlet UILabel *blueValueLabel;
@property (nonatomic) IBOutlet UILabel *alphaValueLabel;

/** 各种颜色调节滑块. */
@property (nonatomic) IBOutlet UISlider *redSlider;
@property (nonatomic) IBOutlet UISlider *greenSlider;
@property (nonatomic) IBOutlet UISlider *blueSlider;
@property (nonatomic) IBOutlet UISlider *alphaSlider;

@end


@implementation LXColorAdjuster

#pragma mark 计算颜色组成值

- (void)setPaletteColor:(UIColor *)paletteColor
{
    if (!_paletteColor) { // 只在第一次外界传入颜色值时才解析.内部调节颜色时不要解析.
        [paletteColor getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
    }

    _paletteColor = paletteColor;
}

#pragma mark 设置预览窗显示的颜色

- (void)setPreviewView:(UIView *)previewView
{
    _previewView = previewView;

    _previewView.backgroundColor    = _paletteColor;
    _previewView.layer.borderColor  = [UIColor grayColor].CGColor;
    _previewView.layer.borderWidth  = 5;
    _previewView.layer.cornerRadius = CGRectGetHeight(_previewView.bounds) / 4;
}

#pragma mark 设置颜色标签显示的值

- (void)setRedValueLabel:(UILabel *)redValueLabel
{
    _redValueLabel = redValueLabel;

    _redValueLabel.text = [NSString stringWithFormat:@"%.f", _red * 255];
}

- (void)setGreenValueLabel:(UILabel *)greenValueLabel
{
    _greenValueLabel = greenValueLabel;

    _greenValueLabel.text = [NSString stringWithFormat:@"%.f", _green * 255];
}

- (void)setBlueValueLabel:(UILabel *)blueValueLabel
{
    _blueValueLabel = blueValueLabel;

    _blueValueLabel.text = [NSString stringWithFormat:@"%.f", _blue * 255];
}

- (void)setAlphaValueLabel:(UILabel *)alphaValueLabel
{
    _alphaValueLabel = alphaValueLabel;

    _alphaValueLabel.text = [NSString stringWithFormat:@"%.2f", _alpha];
}

#pragma mark 设置颜色滑块位置

- (void)setRedSlider:(UISlider *)redSlider
{
    _redSlider = redSlider;

    _redSlider.value = _red * 255;
}

- (void)setGreenSlider:(UISlider *)greenSlider
{
    _greenSlider = greenSlider;

    _greenSlider.value = _green * 255;
}

- (void)setBlueSlider:(UISlider *)blueSlider
{
    _blueSlider = blueSlider;

    _blueSlider.value = _blue * 255;
}

- (void)setAlphaSlider:(UISlider *)alphaSlider
{
    _alphaSlider = alphaSlider;

    _alphaSlider.value = _alpha;
}

#pragma mark 调节颜色

- (IBAction)changeColorAction:(UISlider *)sender
{
    switch (sender.tag) {
        case LXColorRed:
            _red = sender.value;
            _redValueLabel.text   = [NSString stringWithFormat:@"%.f", _red];
            break;

        case LXColorGreen:
            _green = sender.value;
            _greenValueLabel.text = [NSString stringWithFormat:@"%.f", _green];
            break;

        case LXColorBlue:
            _blue = sender.value;
            _blueValueLabel.text  = [NSString stringWithFormat:@"%.f", _blue];
            break;

        case LXColorAlpha:
            _alpha = sender.value;
            _alphaValueLabel.text = [NSString stringWithFormat:@"%.2f", _alpha];
            break;
    }

    _previewView.backgroundColor  = [UIColor colorWithRed:_red   / 255
                                                    green:_green / 255
                                                     blue:_blue  / 255
                                                    alpha:_alpha];
    _paletteColor = _previewView.backgroundColor;
}

@end