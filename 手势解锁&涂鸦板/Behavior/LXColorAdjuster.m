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
@property (nonatomic, strong) IBOutlet UIView *previewView;

/** RGBA 标签. */
@property (nonatomic, strong) IBOutlet UILabel *RGBALabel;

/** 透明度调节滑块. */
@property (nonatomic, strong) IBOutlet UISlider *opacitySlider;

/** 亮度调节滑块. */
@property (nonatomic, strong) IBOutlet UISlider *brightnessSlider;

/** 颜色选择器. */
@property (nonatomic, strong) IBOutlet RSColorPickerView *colorPicker;

@end


@implementation LXColorAdjuster

#pragma mark - 设置预览窗边框

- (void)setPreviewView:(UIView *)previewView
{
    _previewView = previewView;

    _previewView.layer.borderColor  = [UIColor grayColor].CGColor;
    _previewView.layer.cornerRadius = CGRectGetHeight(_previewView.bounds) / 4;
}

#pragma mark - 配置调色盘

- (void)setColorPicker:(RSColorPickerView *)colorPicker
{
    _colorPicker = colorPicker;

    colorPicker.selectionColor  = self.paletteColor;

    self.opacitySlider.value    = self.colorPicker.opacity;
    self.brightnessSlider.value = self.colorPicker.brightness;
}

- (void)setOpacitySlider:(UISlider *)opacitySlider
{
    _opacitySlider = opacitySlider;

    opacitySlider.value = self.colorPicker.opacity;
}

- (void)setBrightnessSlider:(UISlider *)brightnessSlider
{
    _brightnessSlider = brightnessSlider;

    brightnessSlider.value = self.colorPicker.brightness;
}

#pragma mark - 调节亮度

- (IBAction)brightnessChangeAction:(UISlider *)sender
{
    self.colorPicker.brightness = sender.value;
}

#pragma mark - 调节透明度

- (IBAction)alphaChangeAction:(UISlider *)sender
{
    self.colorPicker.opacity = sender.value;
}

#pragma mark - RSColorPickerViewDelegate

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)colorPicker
{
    UIColor *color = [colorPicker selectionColor];

    CGFloat red, green, blue, alpha;
    [[colorPicker selectionColor] getRed:&red green:&green blue:&blue alpha:&alpha];

    self.paletteColor = color;
    
    self.previewView.backgroundColor = color;

    self.RGBALabel.text = [NSString stringWithFormat:@"RGBA: %ld, %ld, %ld, %.2f",
                           (long)(red * 255), (long)(green * 255), (long)(blue * 255), alpha];
}

@end