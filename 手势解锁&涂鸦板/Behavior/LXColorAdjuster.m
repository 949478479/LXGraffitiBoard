//
//  LXColorAdjuster.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXColorAdjuster.h"
#import "RSColorPickerView.h"


@interface LXColorAdjuster () <RSColorPickerViewDelegate>

/** 预览窗. */
@property (nonatomic) IBOutlet UIView *previewView;

/** RGBA 标签. */
@property (nonatomic) IBOutlet UILabel *RGBALabel;

/** 透明度调节滑块. */
@property (nonatomic) IBOutlet UISlider *opacitySlider;

/** 亮度调节滑块. */
@property (nonatomic) IBOutlet UISlider *brightnessSlider;

/** 颜色选择器. */
@property (nonatomic) IBOutlet RSColorPickerView *colorPicker;

@end


@implementation LXColorAdjuster

#pragma mark 设置预览窗边框

- (void)setPreviewView:(UIView *)previewView
{
    _previewView = previewView;

    _previewView.layer.borderColor  = [UIColor grayColor].CGColor;
    _previewView.layer.cornerRadius = CGRectGetHeight(_previewView.bounds) / 4;
}

#pragma mark 配置调色盘

- (void)setColorPicker:(RSColorPickerView *)colorPicker
{
    _colorPicker = colorPicker;

    _colorPicker.selectionColor = _paletteColor;

    _opacitySlider.value    = _colorPicker.opacity;
    _brightnessSlider.value = _colorPicker.brightness;
}

- (void)setOpacitySlider:(UISlider *)opacitySlider
{
    _opacitySlider = opacitySlider;

    _opacitySlider.value = _colorPicker.opacity;
}

- (void)setBrightnessSlider:(UISlider *)brightnessSlider
{
    _brightnessSlider = brightnessSlider;

    _brightnessSlider.value = _colorPicker.brightness;
}

#pragma mark 调节亮度

- (IBAction)brightnessChangeAction:(UISlider *)sender
{
    _colorPicker.brightness = sender.value;
}

#pragma mark 调节透明度

- (IBAction)alphaChangeAction:(UISlider *)sender
{
    _colorPicker.opacity = sender.value;
}

#pragma mark RSColorPickerViewDelegate

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)colorPicker
{
    UIColor *color = [colorPicker selectionColor];

    CGFloat red, green, blue, alpha;
    [[colorPicker selectionColor] getRed:&red green:&green blue:&blue alpha:&alpha];

    _paletteColor = color;
    
    _previewView.backgroundColor = color;

    _RGBALabel.text = [NSString stringWithFormat:@"RGBA: %ld, %ld, %ld, %.2f",
        (NSInteger)(red * 255), (NSInteger)(green * 255), (NSInteger)(blue * 255), alpha];
}

@end