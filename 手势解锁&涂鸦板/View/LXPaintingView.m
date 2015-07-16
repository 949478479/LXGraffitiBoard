//
//  LXPaintingView.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import AssetsLibrary;
#import "LXPaintingView.h"
#import "LXPaintingLayer.h"


#define LXRoundDown(x, scale) ({ \
    CGFloat result; \
    if ( (scale) == 2.0 ) { \
        result = (NSInteger)( (x) * 2.0 ) / 2; \
    } else { \
        result = (NSInteger)(x); \
    } \
    result; \
})


/** 保存失败弹窗标题. */
#define LX_SAVE_FAILURE_TITLE                     @"哎呀"

/** 保存失败弹窗内容. */
#define LX_SAVE_FAILURE_UNAUTHORIZED_MESSAGE      @"没有相册权限,需要先去设置里开启才行的!"
#define LX_SAVE_FAILURE_DISK_INSUFFICIENT_MESSAGE @"存储空间不足了..."

/** 保存失败弹窗按钮标题. */
#define LX_SAVE_FAILURE_ACTION_TITLE              @"好吧..."

/** 保存成功弹窗标题. */
#define LX_SAVE_SUCCESS_TITLE                     @"保存成功!"

/** 保存成功弹窗按钮标题. */
#define LX_SAVE_SUCCESS_ACTION_TITLE              @"太好了~"


@interface LXPaintingView ()

/** 照片图层. */
@property (nonatomic) CALayer *imageLayer;

/** 涂鸦图层. */
@property (nonatomic) LXPaintingLayer *paintingLayer;

/** 能否撤销. */
@property (nonatomic, readwrite) BOOL canUndo;

/** 能否恢复. */
@property (nonatomic, readwrite) BOOL canRedo;

/** 是否应该开始触摸系列事件. */
@property (nonatomic) BOOL touchShouldBegin;

/** 照片图层的 frame. */
@property (nonatomic) CGRect imageLayerFrame;

@end


@implementation LXPaintingView
@dynamic backgroundImage, paintBrush;

#pragma mark - 初始化

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
    _paintingLayer = [LXPaintingLayer layer];
    _imageLayer    = [CALayer layer];
    _imageLayer.contentsScale = [UIScreen mainScreen].scale;

    [_imageLayer addSublayer:_paintingLayer];
    [self.layer  addSublayer:_imageLayer];

    [_paintingLayer addObserver:self
                     forKeyPath:@"canUndo"
                        options:(NSKeyValueObservingOptions)0
                        context:NULL];
    [_paintingLayer addObserver:self
                     forKeyPath:@"canRedo"
                        options:(NSKeyValueObservingOptions)0
                        context:NULL];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (CGRectIsEmpty(_imageLayerFrame)) {
        _imageLayer.frame    = self.bounds;
        _paintingLayer.frame = _imageLayer.bounds;
    } else {
        _imageLayer.frame    = _imageLayerFrame;
        _paintingLayer.frame = _imageLayer.bounds;
    }
}

#pragma mark - 触摸事件处理

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [touches.anyObject locationInView:self];
    point = [_imageLayer convertPoint:point fromLayer:self.layer];

    _touchShouldBegin = CGRectContainsPoint(_imageLayer.bounds, point);

    if (_touchShouldBegin) {
        [_paintingLayer touchAction:touches.anyObject];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchShouldBegin) {
        [_paintingLayer touchAction:touches.anyObject];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchShouldBegin) {
        [_paintingLayer touchAction:touches.anyObject];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchShouldBegin) {
        [_paintingLayer touchAction:touches.anyObject];
    }
}

#pragma mark - 配置画板

- (void)setBackgroundImage:(UIImage *)image
{
    if (!image && !_imageLayer.contents) return;

    [_paintingLayer clear];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    CGFloat layerWidth  = CGRectGetWidth(self.bounds);
    CGFloat layerHeight = CGRectGetHeight(self.bounds);

    CGFloat imageWidth  = image.size.width;
    CGFloat imageHeight = image.size.height;

    // 图片超出画板.
    if (!(imageWidth <= layerWidth && imageHeight <= layerHeight)) {

        // 令图片宽等于画板宽度,根据纵横比计算此时的图片高度.
        imageHeight = layerWidth * imageHeight / imageWidth;

        // 若算出的高度超出了画板高度,则说明假设不成立.这时令图片高度等于画板高度,据此计算高度即可.
        if (imageHeight > layerHeight) {
            imageHeight = layerHeight;
            imageWidth  = imageHeight * imageWidth / image.size.height;
        } else {
            imageWidth  = layerWidth;
        }

        // 对图片宽高进行向下舍入的像素取整.
        CGFloat scale = [UIScreen mainScreen].scale;
        imageWidth    = LXRoundDown(imageWidth, scale);
        imageHeight   = LXRoundDown(imageHeight, scale);
    }

    // 调整照片图层以及涂鸦图层,使之匹配图片大小.
    _imageLayer.position = (CGPoint) { layerWidth / 2, layerHeight / 2 };
    _imageLayer.bounds   = (CGRect)  { .size = { imageWidth ?: layerWidth, imageHeight ?: layerHeight } };
    _paintingLayer.frame = _imageLayer.bounds;
    _imageLayerFrame     = _imageLayer.frame;

    _imageLayer.contents = (__bridge id)image.CGImage;

    [CATransaction commit];
}

- (UIImage *)backgroundImage
{
    return [UIImage imageWithCGImage:(__bridge CGImageRef)(_imageLayer.contents)];
}

- (void)setPaintBrush:(id<LXPaintBrush>)paintBrush
{
    _paintingLayer.paintBrush = paintBrush;
}

- (id<LXPaintBrush>)paintBrush
{
    return _paintingLayer.paintBrush;
}

#pragma mark - 清屏和撤销

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"canUndo"]) {
        self.canUndo = [object canUndo];
    }
    else if ([keyPath isEqualToString:@"canRedo"]) {
        self.canRedo = [object canRedo];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-property-ivar"

- (BOOL)canUndo
{
    return _paintingLayer.canUndo;
}

- (BOOL)canRedo
{
    return _paintingLayer.canRedo;
}

#pragma clang diagnostic pop

- (void)clear
{
    [_paintingLayer clear];
}

- (void)undo
{
    [_paintingLayer undo];
}

- (void)redo
{
    [_paintingLayer redo];
}

#pragma mark - 保存图片

- (void)saveToPhotosAlbum
{
/*  // 之前的实现,感觉太麻烦了.

    // 将当前图层内容渲染为图片.
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // 相册中的原始图片宽高.
    CGSize  originalImageSize   = _imageView.image.size;
    CGFloat originalImageWidth  = originalImageSize.width;
    CGFloat originalImageHeight = originalImageSize.height;

    // 相框宽高.
    CGFloat imageViewWidth  = CGRectGetWidth(_imageView.bounds);
    CGFloat imageViewHeight = CGRectGetHeight(_imageView.bounds);

    // 渲染的图片的实际显示宽高.
    CGFloat renderedImageActualWidth  = imageViewHeight * originalImageWidth / originalImageHeight;
    CGFloat renderedImageActualHeight = imageViewWidth * originalImageHeight / originalImageWidth;

    // 获取渲染的图片对应的 CGImage.
    CGImageRef CG_renderedImage       = renderedImage.CGImage;
    size_t     CG_renderedImageWidth  = CGImageGetWidth(CG_renderedImage);
    size_t     CG_renderedImageHeight = CGImageGetHeight(CG_renderedImage);

    UIImage *finalImage;            // 处理后的最终图片.
    CGRect   clipRect = CGRectNull; // 裁剪范围.

    if (renderedImageActualWidth < imageViewWidth) { // 图片两侧有空白.

        // 换算成像素为单位,为了配合 CGImage.
        CGFloat renderedImageWidthForPixel = [UIScreen mainScreen].scale * renderedImageActualWidth;

        // CGImage 是以像素为单位计算的.
        // 另外 CGImageCreateWithImageInRect 函数先对 rect 调用 CGRectIntegral 函数进行舍入处理.
        // 如果有小数,很可能造成多截取1-2像素,结果就是导致图片外的空白图层被截取,造成边缘有条极细但能看出来的白线.
        // 因此这里先四舍五入浮点数到"整数",从而避免上述情况.
        clipRect = (CGRect) {
            round((CG_renderedImageWidth - renderedImageWidthForPixel) / 2),
            0,
            round(renderedImageWidthForPixel),
            CG_renderedImageHeight
        };

    } else if (renderedImageActualHeight < imageViewHeight) { // 图片上下有空白.

        CGFloat renderedImageHeightForPixel = [UIScreen mainScreen].scale * renderedImageActualHeight;

        clipRect = (CGRect) {
            0,
            round((CG_renderedImageHeight - renderedImageHeightForPixel) / 2),
            CG_renderedImageWidth,
            round(renderedImageHeightForPixel),
        };

    } else { // 由于是 SacleAspectFit, 因此若两边都没空白说明刚好吻合.

        finalImage = renderedImage;
    }

    if (!CGRectIsNull(clipRect)) {

        // 裁剪渲染出的图片中实际有图片的部分,去掉空白区域.
        CGImageRef CG_clippedImage = CGImageCreateWithImageInRect(CG_renderedImage, clipRect);

        // 将裁剪后的 CGImage 转换为最终的 UIImage.
        finalImage = [UIImage imageWithCGImage:CG_clippedImage
                                         scale:renderedImage.scale
                                   orientation:UIImageOrientationUp];
        CGImageRelease(CG_clippedImage);
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(finalImage,
                                       self,
                                       @selector(p_image:didFinishSavingWithError:contextInfo:),
                                       NULL);
    });
*/
    UIGraphicsBeginImageContextWithOptions(_imageLayer.bounds.size, YES, 0);
    [_imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(p_image:didFinishSavingWithError:contextInfo:),
                                       NULL);
    });
}

- (void)p_image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *title, *message, *actionTitle;
    if (error) {
        title = LX_SAVE_FAILURE_TITLE;
        if (error.code == ALAssetsLibraryWriteDiskSpaceError) { // 磁盘空间不足.
            message = LX_SAVE_FAILURE_DISK_INSUFFICIENT_MESSAGE;
        }
        else if (error.code == ALAssetsLibraryDataUnavailableError) { // 没有相册访问权限.
            message = LX_SAVE_FAILURE_UNAUTHORIZED_MESSAGE;
        }
        actionTitle = LX_SAVE_FAILURE_ACTION_TITLE;
    }
    else {
        title = LX_SAVE_SUCCESS_TITLE;
        actionTitle = LX_SAVE_SUCCESS_ACTION_TITLE;
    }

    // FIXME: dismiss 弹窗后会有个 NSMutableArray 对象(貌似是储存 action 用的)出现内存泄露.网上说这是个 bug.
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:actionTitle
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

@end