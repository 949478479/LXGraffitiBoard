//
//  LXViewController.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXViewController.h"
#import "LXUnlockingView.h"


@interface LXViewController ()

@property (weak, nonatomic) IBOutlet LXUnlockingView *unlockingView;

@end


@implementation LXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _unlockingView.completeHandle = ^(NSString *password){
        NSLog(@"password: %@", password);
        return [password isEqualToString:@"0124678"];
    };

    __typeof(self) __weak weakSelf = self;
    _unlockingView.successHandle = ^{
        UIViewController *toVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"LXPaintingViewController"];
        [UIView transitionFromView:weakSelf.view
                            toView:toVC.view
                          duration:1
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
            toVC.view.window.rootViewController = toVC;
        }];
    };
}

- (void)dealloc
{
    NSLog(@"%@ 手势解锁控制器销毁 -------", self);
}

@end