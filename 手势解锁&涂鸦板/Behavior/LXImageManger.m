//
//  LXImageManger.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/9.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXImageManger.h"


/** 自己的图片缓存文件夹路径. */
#define LX_IMAGE_CACHE_PATH \
    [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] \
        stringByAppendingPathComponent:@"LXImageCache"]

/** 指定缓存文件索引并生成保存路径. */
#define LXCacheImagePath(imageIndex) \
    [LX_IMAGE_CACHE_PATH stringByAppendingPathComponent: \
        [NSString stringWithFormat:@"%ld.png", (long)(imageIndex)]]

/** 无效索引. */
static const NSInteger kLXInvalidIndex = -1;


@interface LXImageManger ()

/** 当前图片索引. */
@property (nonatomic) NSInteger imageIndex;

/** 图片总数. */
@property (nonatomic) NSUInteger totalOfImages;

/** 读写图片的串行队列. */
@property (nonatomic) dispatch_queue_t imageIOQueue;

@end


@implementation LXImageManger

#pragma mark - 获取图片管理者

+ (instancetype)sharedManger
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedManger];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageIndex   = kLXInvalidIndex;
        _imageIOQueue = dispatch_queue_create("com.nizi.imageIOQueue", DISPATCH_QUEUE_SERIAL);
        [[NSFileManager defaultManager] createDirectoryAtPath:LX_IMAGE_CACHE_PATH
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return self;
}

#pragma mark - 添加图片

- (void)addImage:(UIImage *)image
{
    _totalOfImages = ++_imageIndex + 1;

    // 后台写入硬盘.
    NSInteger index = _imageIndex;
    dispatch_async(_imageIOQueue, ^{
        [UIImagePNGRepresentation(image) writeToFile:LXCacheImagePath(index) atomically:YES];
    });
}

#pragma mark - 撤销

- (BOOL)canUndo
{
    return _imageIndex >= 0;
}

- (UIImage *)imageForUndo
{
    if (![self canUndo]) return nil;

    if (--_imageIndex == kLXInvalidIndex) return nil;

    __block UIImage *image;
    dispatch_sync(_imageIOQueue, ^{
        image = [UIImage imageWithContentsOfFile:LXCacheImagePath(_imageIndex)];
    });
    return image;
}

#pragma mark - 恢复

- (BOOL)canRedo
{
    return ((NSUInteger)_imageIndex + 1) < _totalOfImages;
}

- (UIImage *)imageForRedo
{
    if (![self canRedo]) return nil;

    __block UIImage *image;
    dispatch_sync(_imageIOQueue, ^{
        image = [UIImage imageWithContentsOfFile:LXCacheImagePath(++_imageIndex)];
    });
    return image;
}

#pragma mark - 移除所有图片

- (void)removeAllImages
{
    _imageIndex = kLXInvalidIndex;
}

@end