//
//  LXImagePicker.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXImagePicker.h"


@interface LXImagePicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/** 关联的视图控制器. */
@property (nonatomic, weak) IBOutlet UIViewController *viewController;

@end


@implementation LXImagePicker

#pragma mark - 选择照片

- (IBAction)pickImageAction:(UIBarButtonItem *)sender
{
    UIImagePickerController *pickerVC = ({
        pickerVC = [UIImagePickerController new];

        pickerVC.delegate   = self;
        pickerVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

        pickerVC.modalPresentationStyle = UIModalPresentationPopover;
        pickerVC.popoverPresentationController.barButtonItem = sender;

        pickerVC;
    });

    [_viewController presentViewController:pickerVC animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _selectedImage = info[UIImagePickerControllerOriginalImage];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    [_viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_viewController dismissViewControllerAnimated:YES completion:nil];
}

@end