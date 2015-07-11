//
//  LXUnlockingViewController
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/4.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXUnlockingViewController.h"
#import "LXUnlockingView.h"


@interface LXUnlockingViewController ()

@property (nonatomic) IBOutlet LXUnlockingView *unlockingView;

@end


@implementation LXUnlockingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _unlockingView.completeHandle = ^(NSString *password){
        NSLog(@"password: %@", password);
        return [password isEqualToString:@"0124678"];
    };

    __typeof(self) __weak weakSelf = self;
    _unlockingView.successHandle = ^{
    
        UIViewController *toVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:
                                  @"LXPaintViewController"];

        [UIView transitionFromView:weakSelf.view
                            toView:toVC.view
                          duration:1
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
            toVC.view.window.rootViewController = toVC;
        }];
    };
}

@end