//
//  LXImageManger.m
//  手势解锁&涂鸦板
//
//  Created by 从今以后 on 15/7/9.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXImageManger.h"


/** 自己的图片缓存文件夹路径. */
static inline NSString * LXImageCachesPath()
{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent:@"LXImageCaches"];
}

/** 指定缓存文件索引并生成保存路径. */
static inline NSString * LXImageCachePathForIndex(NSInteger imageIndex)
{
    return [LXImageCachesPath() stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%ld.png", (long)(imageIndex)]];
}

/** 无效索引. */
static const NSInteger kInvalidIndex = -1;


@interface LXImageManger ()

/** 当前图片索引. */
@property (nonatomic) NSInteger imageIndex;

/** 图片总数. */
@property (nonatomic) NSUInteger totalOfImages;

/** 读写图片的串行队列. */
@property (nonatomic, strong) dispatch_queue_t imageIOQueue;

@end


@implementation LXImageManger

#pragma mark - 获取图片管理者

+ (instancetype)sharedImageManger
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
    return [self sharedImageManger];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageIndex   = kInvalidIndex;
        _imageIOQueue = dispatch_queue_create("com.nizi.imageIOQueue", DISPATCH_QUEUE_SERIAL);
        [[NSFileManager defaultManager] createDirectoryAtPath:LXImageCachesPath()
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return self;
}

#pragma mark - 添加图片

- (void)addImage:(UIImage *)image
{
    self.totalOfImages = ++self.imageIndex + 1;

    // 后台写入硬盘.
    NSInteger index = self.imageIndex;
    dispatch_async(self.imageIOQueue, ^{
        [UIImagePNGRepresentation(image) writeToFile:LXImageCachePathForIndex(index) atomically:YES];
    });
}

#pragma mark - 撤销

- (BOOL)canUndo
{
    return self.imageIndex >= 0;
}

- (UIImage *)imageForUndo
{
    if (![self canUndo]) return nil;

    if (--self.imageIndex == kInvalidIndex) return nil;

    __block UIImage *image;
    dispatch_sync(self.imageIOQueue, ^{
        image = [UIImage imageWithContentsOfFile:LXImageCachePathForIndex(self.imageIndex)];
    });
    return image;
}

#pragma mark - 恢复

- (BOOL)canRedo
{
    return ((NSUInteger)self.imageIndex + 1) < self.totalOfImages;
}

- (UIImage *)imageForRedo
{
    if (![self canRedo]) return nil;

    __block UIImage *image;
    dispatch_sync(self.imageIOQueue, ^{
        image = [UIImage imageWithContentsOfFile:LXImageCachePathForIndex(++self.imageIndex)];
    });
    return image;
}

#pragma mark - 移除所有图片

- (void)removeAllImages
{
    self.imageIndex = kInvalidIndex;

    dispatch_sync(self.imageIOQueue, ^{
        [[NSFileManager defaultManager] removeItemAtPath:LXImageCachesPath() error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtPath:LXImageCachesPath()
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    });
}

@end