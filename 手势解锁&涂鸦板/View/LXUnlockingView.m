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
static const NSInteger kLXButtonCount = 3;

/** 按钮尺寸. */
static const CGFloat   kLXButtonSize  = 74;

/** 线条宽度 */
static const CGFloat   kLXLineWidth   = 10;

/** 线条颜色. */
#define LX_LINE_COLOR [UIColor colorWithRed:144/255.0 green:217/255.0 blue:245/255.0 alpha:1]


@interface LXUnlockingView ()

/** 线条颜色. */
@property (nonatomic) UIColor *lineColor;

/** 当前触摸点. */
@property (nonatomic) CGPoint currentPoint;

/** 连线路径. */
@property (nonatomic) CGMutablePathRef path;

/** 选中的按钮们. */
@property (nonatomic) NSMutableArray *buttons;

@end


@implementation LXUnlockingView

- (void)dealloc
{
    CGPathRelease(_path);
}

#pragma mark 初始化

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

/** 配置九个按钮. */
- (void)p_commonInit
{
    _lineColor = LX_LINE_COLOR;
    _path      = CGPathCreateMutable();
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

/** 布局按钮. */
- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat marginH = ({
        (CGRectGetWidth(self.bounds)  - kLXButtonSize * kLXButtonCount) / (kLXButtonCount + 1);
    });
    CGFloat marginV = ({
        (CGRectGetHeight(self.bounds) - kLXButtonSize * kLXButtonCount) / (kLXButtonCount + 1);
    });

    [self.subviews enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        NSUInteger row = idx / 3, col = idx % 3;
        CGFloat x = (marginH + kLXButtonSize) * col + marginH;
        CGFloat y = (marginV + kLXButtonSize) * row + marginV;
        button.frame = CGRectMake(x, y, kLXButtonSize, kLXButtonSize);
    }];
}

#pragma mark 触摸事件

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
    [self p_handleForTouchesEnded:touches];
}

#pragma mark 绘制图案

- (void)drawRect:(CGRect)rect
{
    if (!_path || CGPathIsEmpty(_path)) return;

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextAddPath(context, _path);
    CGContextAddLineToPoint(context, _currentPoint.x, _currentPoint.y);

    CGContextSetLineWidth(context, kLXLineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);

    CGContextStrokePath(context);
}

#pragma mark 辅助方法

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

#pragma mark 触摸处理

/** 根据触摸位置渲染连线. */
- (void)p_handleForTouchesBeganAndMoved:(NSSet *)touches
{
    CGPoint point1 = _currentPoint;
    CGPoint point2 = CGPointZero;
    CGPoint point3 = CGPointZero;

    _currentPoint = [touches.anyObject locationInView:self];

    BOOL isNewButton = NO; // 是否连接到新按钮(第一个按钮不按新按钮算).
    UIButton *button = [self p_buttonForPoint:_currentPoint];

    if (button && !button.isSelected) { // 触摸到一个新按钮,保存按钮并将按钮中心添加到路径.

        button.selected = YES;
        [_buttons addObject:button];

        CGFloat x = CGRectGetMidX(button.frame);
        CGFloat y = CGRectGetMidY(button.frame);

        if (!_path) {
            _path = CGPathCreateMutable();
        }

        if (CGPathIsEmpty(_path)) {
            CGPathMoveToPoint(_path, NULL, x, y);
        } else {
            isNewButton = YES;

            // 如果连接到新按钮,根据 上一点(point1), 新按钮中点(point2), 上一按钮中点(point3) 计算重绘矩形范围.
            // 该范围肯定是包含当前点的.
            point2 = button.center;
            point3 = CGPathGetCurrentPoint(_path);

            CGPathAddLineToPoint(_path, NULL, x, y);
        }
    }

    if (CGPathIsEmpty(_path)) return; // 连接到按钮才有必要绘制.

    // 如果未连接到新按钮,根据 上一点(point1), 当前点(point2), 上一按钮中点(point3) 计算重绘矩形范围.
    if (!isNewButton) {
        point2 = _currentPoint;
        point3 = CGPathGetCurrentPoint(_path);
    }

    CGRect dirtyRect = [self p_dirtyRectForPoint1:point1
                                           point2:point2
                                           point3:point3
                                     andLineWidth:kLXLineWidth];
    [self setNeedsDisplayInRect:dirtyRect];
}


/** 触摸结束处理. */
- (void)p_handleForTouchesEnded:(NSSet *)touches
{
    if (CGPathIsEmpty(_path)) return; // 连接到按钮才有必要进一步处理.

    // 判断密码正误.
    NSMutableString *password = [NSMutableString stringWithCapacity:9];
    for (UIButton *button in _buttons) {
        [password appendFormat:@"%ld",(long)button.tag];
    }
    BOOL isCorrect = _completeHandle ? _completeHandle(password) : NO;

    // 根据正误重新绘制对应颜色的线条并显示 HUD.
    void (^handleBlock)();

    if (isCorrect) {
        handleBlock = _successHandle;
        _lineColor  = [UIColor greenColor];

        [MBProgressHUD lx_showHudForSuccess:@"终于对了...O(∩_∩)O~"];
    }
    else {
        handleBlock = _failureHandle;
        _lineColor  = [UIColor redColor];

        [MBProgressHUD lx_showHudForError:@"密码不对...⊙﹏⊙汗"];
    }

    _currentPoint = CGPathGetCurrentPoint(_path); // 为了不将松手时的触摸点绘制进去,导致一根线连到外面.
    [self setNeedsDisplay];

    // 让线条显示 1s 再清除屏幕上的线条.
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{

        [_buttons makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
        [_buttons removeAllObjects];
        _lineColor = LX_LINE_COLOR;

        CGPathRelease(_path);
        _path = NULL;

        [self setNeedsDisplay];

        if (handleBlock) handleBlock();
    });
}

@end