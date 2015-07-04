//
//  MBProgressHUD+LX.h
//  我的涂鸦板
//
//  Created by nizi on 15/6/12.
//  Copyright (c) 2015年 nizi. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (LX)
/** 显示提示成功的 HUD, 1s 后自动消失. */
+ (void)lx_showHudForSuccess:(NSString *)message;
/** 显示提示错误的 HUD, 1s 后自动消失. */
+ (void)lx_showHudForError:(NSString *)message;
@end
