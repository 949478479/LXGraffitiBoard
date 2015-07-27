//
//  LXBaseBrush.h
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import UIKit;
#import "LXPaintBrush.h"


/** 涂鸦工具. */
typedef NS_ENUM(NSUInteger, LXBrushType) {
    /** 画笔. */
    LXBrushTypePencil,
    /** 橡皮. */
    LXBrushTypeEraser,
    /** 直线. */
    LXBrushTypeLine,
    /** 虚线. */
    LXBrushTypeDashLine,
    /** 矩形. */
    LXBrushTypeRectangle,
    /** 方形. */
    LXBrushTypeSquare,
    /** 椭圆. */
    LXBrushTypeEllipse,
    /** 正圆. */
    LXBrushTypeCircle,
    /** 箭头. */
    LXBrushTypeArrow,
};


@interface LXBaseBrush : NSObject <LXPaintBrush>

/** 初始点. */
@property (nonatomic, readonly) CGPoint startPoint;

/** 上一点. */
@property (nonatomic, readonly) CGPoint previousPoint;

/** 当前点. */
@property (nonatomic, readonly) CGPoint currentPoint;


/** 配置上下文. */
- (void)configureContext:(CGContextRef)context;

/** 创建对应类型的涂鸦工具. */
+ (id<LXPaintBrush>)brushWithType:(LXBrushType)brushType;

@end