//
//  LXPaintingLayer.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/5.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXPaintingLayer.h"
#import "LXPaintBrush.h"
#import "LXImageManger.h"


/** 是否显示重绘的矩形范围. */
#define SHOW_REDRAW_RECT 0


@interface LXPaintingLayer ()

/** 画板内容截图. */
@property (nonatomic) UIImage *bitmap;

/** 画刷是否应该绘制. */
@property (nonatomic) BOOL brushShouldDraw;

/** 能否撤销. */
@property (readwrite, nonatomic) BOOL canUndo;

/** 能否恢复. */
@property (readwrite, nonatomic) BOOL canRedo;

/** 图片管理者. */
@property (nonatomic) LXImageManger *imageManger;

@end


@implementation LXPaintingLayer

#pragma mark 初始化

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageManger = [LXImageManger sharedManger];
        self.drawsAsynchronously = YES;
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    // 绘制过程中 contents 会变动,返回 nil, 否则会有晃瞎狗眼的隐式动画.
    if ([event isEqualToString:@"contents"]) {
        return nil;
    }
    return [super actionForKey:event];
}

#pragma mark 绘图

- (void)drawInContext:(CGContextRef)ctx
{
    // 将上次的图层内容作为位图渲染.
    if (_bitmap) {
        // 翻转坐标系为原点在左下角的 CG 坐标系.
        CGContextTranslateCTM(ctx, 0, CGRectGetHeight(self.bounds));
        CGContextScaleCTM(ctx, 1, -1);

        CGContextDrawImage(ctx, self.bounds, _bitmap.CGImage);

        // 翻转回原点在左上角的 UI 坐标系.
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -CGRectGetHeight(self.bounds));
    }

    // 使用画刷对象绘图.
    if (_brushShouldDraw) {
        [_paintBrush drawInContext:ctx];
    }

#if SHOW_REDRAW_RECT
    {   // 这段代码可以显示每次的重绘区域.
        CGRect redrawRect = CGContextGetClipBoundingBox(ctx);
        redrawRect = CGRectInset(redrawRect, 0.5, 0.5);
        CGContextSetLineWidth(ctx, 1);
        CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 1);
        CGContextStrokeRect(ctx, redrawRect);
    }
#endif
}

#pragma mark 触摸处理

- (void)touchAction:(UITouch *)touch
{
    if (!_paintBrush) return;

    CGPoint point = [touch locationInView:touch.view];
    point = [self convertPoint:point fromLayer:touch.view.layer];

    switch (touch.phase) {
        case UITouchPhaseMoved:

            [_paintBrush moveToPoint:point];

            break;

        case UITouchPhaseBegan:

            _brushShouldDraw = YES;
            [_paintBrush beginAtPoint:point];

            break;

        case UITouchPhaseEnded:
        case UITouchPhaseCancelled:

            [_paintBrush end];

            _brushShouldDraw = NO;
            self.canUndo     = YES;
            self.canRedo     = NO;

            // 截取图层当前的图像,下次直接作为位图绘制.
            // 这里必须为 NO, 由于重绘区域是个矩形,路径是条线条,如果为不透明则使用橡皮时矩形剩余部分都会渲染为黑色.
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
            [self renderInContext:UIGraphicsGetCurrentContext()];
            _bitmap = UIGraphicsGetImageFromCurrentImageContext();
            [_imageManger addImage:_bitmap];
            UIGraphicsEndImageContext();

            break;

        case UITouchPhaseStationary:
            break; // 占位用,不然有警告...
    }

    if (_paintBrush.needsDraw) {
        [self setNeedsDisplayInRect:_paintBrush.redrawRect];
    }
}

#pragma mark 清屏 撤销 恢复

- (void)clear
{
    if (!_bitmap) return;

    _bitmap       = nil;
    self.canUndo  = NO;
    self.canRedo  = NO;
    
    [_imageManger removeAllImages];

    [self setNeedsDisplay];
}

- (void)undo
{
    if (!_canUndo) return;

    _bitmap      = [_imageManger imageForUndo];
    self.canUndo = [_imageManger canUndo];
    self.canRedo = YES;

    [self setNeedsDisplay];
}

- (void)redo
{
    if (!_canRedo) return;

    _bitmap = [_imageManger imageForRedo];

    self.canRedo = [_imageManger canRedo];
    self.canUndo = YES;

    [self setNeedsDisplay];
}

@end