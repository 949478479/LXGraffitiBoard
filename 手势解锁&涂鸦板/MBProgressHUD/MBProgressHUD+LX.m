//
//  MBProgressHUD+LX.m
//  我的涂鸦板
//
//  Created by nizi on 15/6/12.
//  Copyright (c) 2015年 nizi. All rights reserved.
//

#import "MBProgressHUD+LX.h"
#import "AppDelegate.h"

#define LX_KEY_WINDOW ((AppDelegate *)[UIApplication sharedApplication].delegate).window

@implementation MBProgressHUD (LX)

#pragma mark - 公共方法

+ (void)lx_showHudForSuccess:(NSString *)message
{
    [self lx_showHudWithMessage:message andIcon:@"37x-Checkmark"];
}

+ (void)lx_showHudForError:(NSString *)message
{
    [self lx_showHudWithMessage:message andIcon:@"error.png"];
}

#pragma mark - 私有方法

+ (void)lx_showHudWithMessage:(NSString *)message andIcon:(NSString *)icon
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:LX_KEY_WINDOW];
    hud.labelText = message;
    hud.removeFromSuperViewOnHide = YES;
    
    NSString *iconName = [NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    hud.mode = MBProgressHUDModeCustomView;
    
    [LX_KEY_WINDOW addSubview:hud];

    [hud show:YES];
    [hud hide:YES afterDelay:1];
}

@end
