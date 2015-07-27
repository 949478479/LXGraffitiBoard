//
//  LXUnlockingView.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXUnlockingView.h"
#import "MBProgressHUD+LX.h"


/** 每行/列按钮个数. */
static const NSInteger kButtonCount = 3;

/** 按钮尺寸. */
static const CGFloat   kButtonSize  = 74;

/** 线条宽度 */
static const CGFloat   kLineWidth   = 10;

/** 线条颜色. */
static inline UIColor * LXLineColor()
{
    return [UIColor colorWithRed:144/255.0 green:217/255.0 blue:245/255.0 alpha:1];
}


@interface LXUnlockingView ()
{
    CGMutablePathRef _path; /** 连线路径. */
}

/** 当前触摸点. */
@property (nonatomic) CGPoint currentPoint;

/** 线条颜色. */
@property (nonatomic, strong) UIColor *lineColor;

/** 选中的按钮们. */
@property (nonatomic, strong) NSMutableArray *buttons;

@end


@implementation LXUnlockingView

- (void)dealloc
{
    if (_path) {
        CGPathRelease(_path);
    }
}

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
- (void)p_commonInit
{
    _lineColor = LXLineColor();
    _buttons   = [NSMutableArray new];

    for (NSInteger i = 0; i < 9; ++i) {

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

        button.tag = i;
        button.userInteractionEnabled = NO;

        [button setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"]
                          forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"]
                          forState:UIControlStateSelected];

        [self addSubview:button];
    }

    self.layer.drawsAsynchronously = YES;
}
#pragma clang diagnostic pop

- (void)layoutSubviews
{
    [super layoutSubviews];

    // 布局按钮.
    CGFloat marginH = ({
        (CGRectGetWidth(self.bounds)  - kButtonSize * kButtonCount) / (kButtonCount + 1);
    });
    CGFloat marginV = ({
        (CGRectGetHeight(self.bounds) - kButtonSize * kButtonCount) / (kButtonCount + 1);
    });

    [self.subviews enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        NSUInteger row = idx / 3, col = idx % 3;
        CGFloat x      = (marginH + kButtonSize) * col + marginH;
        CGFloat y      = (marginV + kButtonSize) * row + marginV;
        button.frame   = CGRectMake(x, y, kButtonSize, kButtonSize);
    }];
}

#pragma mark - 触摸事件

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self p_handleForTouchesBeganAndMoved:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self p_handleForTouchesBeganAndMoved:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self p_handleForTouchesEndedOrCancelled:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self p_handleForTouchesEndedOrCancelled:touches];
}

#pragma mark - 绘制图案

- (void)drawRect:(CGRect)rect
{
    if (!_path || CGPathIsEmpty(_path)) return;

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextAddPath(context, _path);
    CGContextAddLineToPoint(context, self.currentPoint.x, self.currentPoint.y);

    CGContextSetLineWidth(context, kLineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);

    CGContextStrokePath(context);
}

#pragma mark - 辅助方法

/** 返回触摸点位置对应的按钮,若不在任何按钮范围内则返回 nil. */
- (UIButton *)p_buttonForPoint:(CGPoint)point
{
    for (UIButton *button in self.subviews) {
        if (CGRectContainsPoint(button.frame, point)) {
            return button;
        }
    }
    return nil;
}

/** 包含给定三个点的矩形范围,这里即需要重新渲染的范围. */
- (CGRect)p_dirtyRectForPoint1:(CGPoint)point1
                        point2:(CGPoint)point2
                        point3:(CGPoint)point3
                  andLineWidth:(CGFloat)lineWidth
{
    CGFloat minX = fmin(fmin(point1.x, point2.x), point3.x) - lineWidth / 2;
    CGFloat minY = fmin(fmin(point1.y, point2.y), point3.y) - lineWidth / 2;
    CGFloat maxX = fmax(fmax(point1.x, point2.x), point3.x) + lineWidth / 2;
    CGFloat maxY = fmax(fmax(point1.y, point2.y), point3.y) + lineWidth / 2;

    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

#pragma mark - 触摸过程处理

- (void)p_handleForTouchesBeganAndMoved:(NSSet *)touches
{
    CGPoint point1    = self.currentPoint;
    CGPoint point2    = CGPointZero;
    CGPoint point3    = CGPointZero;

    self.currentPoint = [touches.anyObject locationInView:self];

    UIButton *button  = [self p_buttonForPoint:self.currentPoint];
    BOOL isNewButton  = [self p_addNewButton:button];

    if (CGPathIsEmpty(_path)) return; // 连接到按钮才有必要绘制.

    // 如果连接到新按钮,根据 上一点(point1), 新按钮中点(point2), 上一按钮中点(point3) 计算重绘矩形范围.
    if (isNewButton) {
        point2 = button.center;
        point3 = [self.buttons[self.buttons.count - 2] center];
    }
    // 如果未连接到新按钮,根据 上一点(point1), 当前点(point2), 上一按钮中点(point3) 计算重绘矩形范围.
    else {
        point2 = self.currentPoint;
        point3 = CGPathGetCurrentPoint(_path);
    }

    CGRect dirtyRect = [self p_dirtyRectForPoint1:point1
                                           point2:point2
                                           point3:point3
                                     andLineWidth:kLineWidth];
    [self setNeedsDisplayInRect:dirtyRect];
}

- (BOOL)p_addNewButton:(UIButton *)button
{
    if (!button || button.isSelected) return NO;

    button.selected = YES;
    [self.buttons addObject:button];

    if (!_path) {
        _path = CGPathCreateMutable();
    }

    if (CGPathIsEmpty(_path)) {
        CGPathMoveToPoint(_path, NULL, button.center.x, button.center.y);
        return NO; // 第一个按钮不按新按钮算.
    } else {
        CGPathAddLineToPoint(_path, NULL, button.center.x, button.center.y);
        return YES;
    }
}

#pragma mark - 触摸结束处理

- (void)p_handleForTouchesEndedOrCancelled:(NSSet *)touches
{
    if (CGPathIsEmpty(_path)) return; // 连接到按钮才有必要进一步处理.

    BOOL isCorrect = [self p_checkPassword];

    void (^completion)() = [self p_redrawByAccordingToIsCorrect:isCorrect];

    [self p_clearScreenWithCompletion:completion];
}

- (BOOL)p_checkPassword
{
    NSMutableString *password = [NSMutableString stringWithCapacity:9];
    for (UIButton *button in self.buttons) {
        [password appendFormat:@"%ld",(long)button.tag];
    }
    return self.completeHandle ? self.completeHandle(password) : NO;
}

- (void (^)())p_redrawByAccordingToIsCorrect:(BOOL)isCorrect
{
    void (^completion)();

    if (isCorrect) {
        completion  = self.successHandle;
        self.lineColor = [UIColor greenColor];

        [MBProgressHUD lx_showHudForSuccess:@"终于对了...O(∩_∩)O~"];
    }
    else {
        completion  = self.failureHandle;
        self.lineColor = [UIColor redColor];

        [MBProgressHUD lx_showHudForError:@"密码不对...⊙﹏⊙汗"];
    }

    // 为了不将松手时的触摸点绘制进去,导致一根线连到外面.
    self.currentPoint = CGPathGetCurrentPoint(_path);
    [self setNeedsDisplay];

    return completion;
}

- (void)p_clearScreenWithCompletion:(void (^)())completion
{
    // 让线条显示 1s 再清除屏幕上的线条.
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{

        [self.buttons makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
        [self.buttons removeAllObjects];

        self.lineColor = LXLineColor();

        if (_path) {
            CGPathRelease(_path);
            _path = NULL;
        }

        [self setNeedsDisplay];

        if (completion) completion();
    });
}

@end