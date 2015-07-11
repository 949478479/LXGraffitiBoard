//
//  LXImagePicker.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/6.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXImagePicker.h"


@interface LXImagePicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIViewController *viewController;

@property (nonatomic) UIPopoverController *popover;

@end


@implementation LXImagePicker

#pragma mark 选择照片

- (IBAction)pickImageAction:(UIBarButtonItem *)sender
{
    UIImagePickerController *pickerVC = [UIImagePickerController new];
    pickerVC.delegate   = self;
    pickerVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

    _popover = [[UIPopoverController alloc] initWithContentViewController:pickerVC];
    _popover.delegate = self;
    [_popover presentPopoverFromBarButtonItem:sender
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _selectedImage = info[UIImagePickerControllerOriginalImage];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    [_popover dismissPopoverAnimated:YES];
    _popover = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_popover dismissPopoverAnimated:YES];
    _popover = nil;
}

#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popover = nil;
}

@end