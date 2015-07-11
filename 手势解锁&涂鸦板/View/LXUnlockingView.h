//
//  LXUnlockingView.h
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import UIKit;


@interface LXUnlockingView : UIView

/** 完成回调. */
@property (copy, nonatomic) BOOL (^completeHandle)(NSString *password);

/** 成功回调. */
@property (copy, nonatomic) void (^successHandle)();

/** 失败回调. */
@property (copy, nonatomic) void (^failureHandle)();

@end