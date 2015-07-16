//
//  LXPaintControlView.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXBaseBrush.h"
#import "LXPaintingView.h"
#import "LXPaintControlView.h"
#import "LXImagePicker.h"


/** 功能操作. */
typedef NS_ENUM(NSUInteger, LXActionType){
    /** 撤销. */
    LXActionTypeUndo,
    /** 恢复. */
    LXActionTypeRedo,
    /** 清屏. */
    LXActionTypeClear,
    /** 保存. */
    LXActionTypeSave,
};


/** 画笔工具类型. */
typedef NS_ENUM(NSUInteger, LXPaintBrushType) {
    /** 画笔. */
    LXPaintBrushTypePencil,
    /** 橡皮. */
    LXPaintBrushTypeEraser,
    /** 直线. */
    LXPaintBrushTypeLine,
    /** 虚线. */
    LXPaintBrushTypeDashLine,
    /** 矩形. */
    LXPaintBrushTypeRectangle,
    /** 方形. */
    LXPaintBrushTypeSquare,
    /** 椭圆. */
    LXPaintBrushTypeEllipse,
    /** 正圆. */
    LXPaintBrushTypeCircle,
    /** 箭头. */
    LXPaintBrushTypeArrow,
};


@interface LXPaintControlView () <UIBarPositioningDelegate>

/** 导航栏. */
@property (nonatomic) IBOutlet UINavigationItem *navItem;

/** 涂鸦板. */
@property (nonatomic) IBOutlet LXPaintingView *paintingView;

/** 预览小窗口. */
@property (nonatomic) IBOutlet UIView   *previewView;

/** 线条宽度滑块. */
@property (nonatomic) IBOutlet UISlider *lineWidthSlider;

/** 撤销按钮. */
@property (nonatomic) IBOutlet UIButton *undoButton;

/** 恢复按钮. */
@property (nonatomic) IBOutlet UIButton *redoButton;

/** 画笔类型控制器. */
@property (nonatomic) IBOutlet UISegmentedControl *brushTypeControl;

/** 选中的颜色按钮. */
@property (nonatomic) IBOutlet UIButton *selectedColorButton;

/** 颜色按钮们. */
@property (nonatomic) IBOutletCollection(UIButton) NSArray *colorButtons;

@end


@implementation LXPaintControlView

#pragma mark - 初始化

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self p_previewBrush];
    [self p_setupPaintBrush];
    [self p_setupNavigationItem];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"canUndo"]) {
        _undoButton.enabled = _paintingView.canUndo;
    }
    else if ([keyPath isEqualToString:@"canRedo"]) {
        _redoButton.enabled = _paintingView.canRedo;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 配置画刷

- (void)p_setupPaintBrush
{
    // 创建并设置画刷.
    id<LXPaintBrush> paintBrush = [LXBaseBrush brushWithType:LXBrushTypePencil];
    paintBrush.lineWidth        = _lineWidthSlider.value;
    paintBrush.lineColor        = _selectedColorButton.backgroundColor;
    _paintingView.paintBrush    = paintBrush;

    // 注册 KVO 方便更新按钮状态.
    [_paintingView addObserver:self
                    forKeyPath:@"canUndo"
                       options:(NSKeyValueObservingOptions)0
                       context:NULL];
    [_paintingView addObserver:self
                    forKeyPath:@"canRedo"
                       options:(NSKeyValueObservingOptions)0
                       context:NULL];
}

#pragma mark - 配置导航栏

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached; // 调整导航栏紧贴屏幕顶部.
}

- (void)p_setupNavigationItem
{
    UIBarButtonItem *spacerItem      = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:nil
                                                                       action:nil];

    UIBarButtonItem *deleteImageItem = [[UIBarButtonItem alloc] initWithTitle:@"❌删除照片"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(deleteImageAction)];

    UIBarButtonItem *clearItem       = [[UIBarButtonItem alloc] initWithTitle:@"♻️清屏"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(clearAction)];

    UIBarButtonItem *saveItem        = [[UIBarButtonItem alloc] initWithTitle:@"💾保存"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(saveAction)];

    _navItem.leftBarButtonItems = @[ _navItem.leftBarButtonItem, spacerItem,
                                     deleteImageItem, spacerItem,
                                     clearItem, spacerItem,
                                     saveItem ];

    UIBarButtonItem *resetColorItem = [[UIBarButtonItem alloc] initWithTitle:@"🔃重置颜色"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(resetColorAction)];
                                                                      
    _navItem.rightBarButtonItems = @[ _navItem.rightBarButtonItem, spacerItem, resetColorItem ];
}

#pragma mark - 预览画笔

- (void)p_previewBrush
{
    CALayer *previewLayer = _previewView.layer.sublayers.lastObject;
    if (!previewLayer) {
        previewLayer = [CALayer layer];
        previewLayer.position = (CGPoint) {
            CGRectGetMidX(_previewView.bounds), CGRectGetMidY(_previewView.bounds)
        };
        [_previewView.layer addSublayer:previewLayer];
    }
    previewLayer.bounds = (CGRect) {
        .size = { _lineWidthSlider.value, _lineWidthSlider.value }
    };
    previewLayer.cornerRadius    = CGRectGetWidth(previewLayer.bounds) / 2;
    previewLayer.backgroundColor = _selectedColorButton.backgroundColor.CGColor;
}

#pragma mark - 设置线条粗细和颜色

- (IBAction)selectLineWidthAction:(UISlider *)sender
{
    _paintingView.paintBrush.lineWidth = sender.value;

    [self p_previewBrush];
}

- (IBAction)selectLineColorAction:(UIButton *)sender
{
    sender.enabled = NO;
    [sender setTitle:@"🎨" forState:UIControlStateNormal];

    _selectedColorButton.enabled = YES;
    [_selectedColorButton setTitle:nil forState:UIControlStateNormal];
    _selectedColorButton = sender;

    _paintingView.paintBrush.lineColor = sender.backgroundColor;

    [self p_previewBrush];
}

#pragma mark - 调色盘

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColorButton.backgroundColor = selectedColor;
    _paintingView.paintBrush.lineColor   = selectedColor;

    [self p_previewBrush];
}

- (UIColor *)selectedColor
{
    return _selectedColorButton.backgroundColor;
}

#pragma mark - 重置颜色按钮

- (void)resetColorAction
{
    for (UIButton *button in _colorButtons) {
        button.backgroundColor = button.tintColor;
    }

    _paintingView.paintBrush.lineColor = _selectedColorButton.backgroundColor;

    [self p_previewBrush];
}

#pragma mark - 选择画笔工具

- (IBAction)selectBrushAction:(UISegmentedControl *)sender
{
    id<LXPaintBrush> paintBrush;

    switch (sender.selectedSegmentIndex) {
        case LXPaintBrushTypePencil:
            paintBrush = [LXBaseBrush brushWithType:LXBrushTypePencil];
            break;
            
        case LXPaintBrushTypeEraser:
            paintBrush = [LXBaseBrush brushWithType:LXBrushTypeEraser];
            break;

        case LXPaintBrushTypeLine:
            paintBrush = [LXBaseBrush brushWithType:LXBrushTypeLine];
            break;

        case LXPaintBrushTypeDashLine:
            paintBrush = [LXBaseBrush brushWithType:LXBrushTypeDashLine];
            break;

        case LXPaintBrushTypeRectangle:
            paintBrush = [LXBaseBrush brushWithType:LXBrushTypeRectangle];
            break;

        case LXPaintBrushTypeSquare:
            paintBrush = [LXBaseBrush brushWithType:LXBrushTypeSquare];
            break;

        case LXPaintBrushTypeEllipse:
            paintBrush = [LXBaseBrush brushWithType:LXBrushTypeEllipse];
            break;

        case LXPaintBrushTypeCircle:
            paintBrush = [LXBaseBrush brushWithType:LXBrushTypeCircle];
            break;

        case LXPaintBrushTypeArrow:
            paintBrush = [LXBaseBrush brushWithType:LXBrushTypeArrow];
            break;
    }

    paintBrush.lineWidth = _lineWidthSlider.value;
    paintBrush.lineColor = _selectedColorButton.backgroundColor;

    _paintingView.paintBrush = paintBrush;
}

#pragma mark - 图片选取完成

- (IBAction)didSelectImageAction:(LXImagePicker *)sender
{
    _paintingView.backgroundImage = sender.selectedImage;
}

#pragma mark - 删除照片

- (void)deleteImageAction
{
    _paintingView.backgroundImage = nil;
}

#pragma mark - 清屏 保存 撤销 恢复

- (void)clearAction
{
    [_paintingView clear];
}

- (void)saveAction
{
    [_paintingView saveToPhotosAlbum];
}

- (IBAction)undoAction:(UIButton *)sender
{
    [_paintingView undo];
}

- (IBAction)redoAction:(id)sender
{
    [_paintingView redo];
}

@end