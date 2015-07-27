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

/** 选中的图片. */
@property (nonatomic, readwrite, strong) UIImage *selectedImage;

@end


@implementation LXImagePicker

#pragma mark - 选择照片

- (IBAction)pickImageAction:(UIBarButtonItem *)sender
{
    UIImagePickerController *pickerVC = [UIImagePickerController new];

    pickerVC.delegate   = self;
    pickerVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

    pickerVC.modalPresentationStyle = UIModalPresentationPopover;
    pickerVC.popoverPresentationController.barButtonItem = sender;

    [self.viewController presentViewController:pickerVC animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.selectedImage = info[UIImagePickerControllerOriginalImage];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end