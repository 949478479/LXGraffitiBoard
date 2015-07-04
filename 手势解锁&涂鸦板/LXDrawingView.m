//
//  LXDrawingView.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXDrawingView.h"
#import "MBProgressHUD+LX.h"


@interface LXDrawingView ()

/** 所有绘图路径. */
@property (nonatomic) NSMutableArray *paths;

/** 所有线条颜色. */
@property (nonatomic) NSMutableArray *lineColors;

/** 所有线条宽度. */
@property (nonatomic) NSMutableArray *lineWidths;

/** 上一点. */
@property (nonatomic) CGPoint previousPoint;

/** 当前点. */
@property (nonatomic) CGPoint currentPoint;

/** 画板内容是否为空. */
@property (readwrite, nonatomic, getter=isEmpty) BOOL empty;

@end


@implementation LXDrawingView

#pragma mark 初始化

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit
{
    _empty = YES;
    _paths = [NSMutableArray array];
    _lineColors = [NSMutableArray array];
    _lineWidths = [NSMutableArray array];

    self.layer.drawsAsynchronously = YES;
}

#pragma mark 触摸事件

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self p_handleWithTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self p_handleWithTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self p_handleWithTouches:touches];
}

#pragma mark 绘制图案

- (void)drawRect:(CGRect)rect
{
    [_paths enumerateObjectsUsingBlock:^(id path, NSUInteger idx, BOOL *stop) {
        [(UIColor *)_lineColors[idx] set];
        [path stroke];
    }];
}

#pragma mark 辅助方法

/** 获取需要重新渲染的区域. */
- (CGRect)p_dirtyRectForStartPoint:(CGPoint)start endPoint:(CGPoint)end lineWidth:(CGFloat)lineWidth
{
    CGFloat minX = fmin(start.x, end.x) - lineWidth / 2;
    CGFloat minY = fmin(start.y, end.y) - lineWidth / 2;
    CGFloat maxX = fmax(start.x, end.x) + lineWidth / 2;
    CGFloat maxY = fmax(start.y, end.y) + lineWidth / 2;

    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

/** 根据 path 的 bounds 获取需要重新渲染的区域 */
- (CGRect)p_dirtyRectForPathBounds:(CGRect)bounds lineWidth:(CGFloat)lineWidth
{
    return CGRectInset(bounds, -lineWidth / 2, -lineWidth / 2);
}

/** 保存显示提示信息. */
- (void)p_image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // FIXME: dismiss 弹窗后会有个 NSMutableArray 对象(貌似是储存 action 用的)内存泄露.网上说这是个 bug.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"哎呀"
                                                                           message:@"没有相册权限,需要先去设置里开启才行!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"好吧..."
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        } else {
            [MBProgressHUD lx_showHudForSuccess:@"保存成功!"];
        }
    });
}

#pragma mark 绘图逻辑

/** 添加触摸点到路径. */
- (void)p_handleWithTouches:(NSSet *)touches
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];

    if (touch.phase == UITouchPhaseMoved) { // 添加移动点到当前路径.

        [[_paths lastObject] addLineToPoint:point];

        _previousPoint = _currentPoint;
        _currentPoint = point;

    } else if (touch.phase == UITouchPhaseBegan) { // 创建新路径并设置属性.

        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = _lineWidth;
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;

        [path moveToPoint:point];
        [path addLineToPoint:point]; // 为了点下去就能渲染出一个点.

        _previousPoint = point;
        _currentPoint = point;

        [_paths addObject:path];
        [_lineColors addObject:_lineColor];
        [_lineWidths addObject:@(_lineWidth)];

        self.empty = NO;

        if (_willBeginDrawingNotify) _willBeginDrawingNotify(self); // 通知画板即将开始绘制.

    } else if (touch.phase == UITouchPhaseEnded) {

        if (_willEndDrawingNotify) _willEndDrawingNotify(self); // 通知画板即将结束绘制.
    }

    [self setNeedsDisplayInRect:[self p_dirtyRectForStartPoint:_previousPoint
                                                      endPoint:_currentPoint
                                                     lineWidth:_lineWidth]];
}

#pragma mark 公共方法

/** 清屏. */
- (void)clear
{
    if (!_paths.count) return;

    [_paths removeAllObjects];
    [_lineColors removeAllObjects];
    [_lineWidths removeAllObjects];

    self.empty = YES;

    [self setNeedsDisplay];
}

/** 回退. */
- (void)back
{
    // 获取最后一笔的路径和宽度.
    UIBezierPath *lastPath = _paths.lastObject;
    if (!lastPath) return;
    CGFloat lastLineWidth = [_lineWidths.lastObject doubleValue];

    // 移除最后一笔的各种记录.
    [_paths removeLastObject];
    [_lineColors removeLastObject];
    [_lineWidths removeLastObject];

    self.empty = _paths.count == 0;

    // 以最后一笔的路径配合宽度设置重绘范围.
    CGRect dirtyRect = [self p_dirtyRectForPathBounds:lastPath.bounds lineWidth:lastLineWidth];
    [self setNeedsDisplayInRect:dirtyRect];
}

/** 保存到系统相册. */
- (void)save
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(p_image:didFinishSavingWithError:contextInfo:), NULL);
    });
}
@end