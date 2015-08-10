//
//  VIPhotoView.m
//  VIPhotoViewDemo
//
//  Created by Vito on 1/7/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

#import "VIPhotoView.h"

@interface UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size;

@end

@implementation UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = CGSizeMake(self.size.width / self.scale,
                                  self.size.height / self.scale);
    
    CGFloat widthRatio = imageSize.width / size.width;
    CGFloat heightRatio = imageSize.height / size.height;
    
    if (widthRatio > heightRatio) {
        imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
    } else {
        imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
    }
    
    return imageSize;
}

@end

@interface UIImageView (VIUtil)

- (CGSize)contentSize;

@end

@implementation UIImageView (VIUtil)

- (CGSize)contentSize
{
    return [self.image sizeThatFits:self.bounds.size];
}

@end

@interface VIPhotoView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic) BOOL rotating;
@property (nonatomic) CGSize minSize;

@end

@implementation VIPhotoView

+ (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image {
    return [[self alloc] initWithFrame:frame andImage:image];
}

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.bouncesZoom = YES;
        
        // Add container view
        UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:containerView];
        _containerView = containerView;
        
        // Add image view
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = containerView.bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [containerView addSubview:imageView];
        _imageView = imageView;
        
        // Fit container view's size to image size
        CGSize imageSize = imageView.contentSize;
        self.containerView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
        imageView.center = CGPointMake(imageSize.width / 2, imageSize.height / 2);
        
        self.contentSize = imageSize;
        self.minSize = imageSize;
        
        
        [self setMaxMinZoomScale];
        
        // Center containerView by set insets
        [self centerContent];
        
        // Setup other events
        [self setupGestureRecognizer];
        [self setupRotationNotification];
        
        //背景颜色黑色
        [self setBackgroundColor:[UIColor blackColor]];
        
        //视图在最前面
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow addSubview:self];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.rotating) {
        self.rotating = NO;
        
        // update container view frame
        CGSize containerSize = self.containerView.frame.size;
        BOOL containerSmallerThanSelf = (containerSize.width < CGRectGetWidth(self.bounds)) && (containerSize.height < CGRectGetHeight(self.bounds));
        
        CGSize imageSize = [self.imageView.image sizeThatFits:self.bounds.size];
        CGFloat minZoomScale = imageSize.width / self.minSize.width;
        self.minimumZoomScale = minZoomScale;
        if (containerSmallerThanSelf || self.zoomScale == self.minimumZoomScale) { // 宽度或高度 都小于 self 的宽度和高度
            self.zoomScale = minZoomScale;
        }
        
        // Center container view
        [self centerContent];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupRotationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)setupGestureRecognizer
{
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandler:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.numberOfTouchesRequired = 1;
    [_containerView addGestureRecognizer:singleTapGesture];
    
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    [_containerView addGestureRecognizer:doubleTapGesture];
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerContent];
}

#pragma mark - GestureRecognizer

//删除图片视图
- (void)singleTapHandler:(UITapGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)doubleTapHandler:(UITapGestureRecognizer *)recognizer
{
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else if (self.zoomScale < self.maximumZoomScale) {
        CGPoint location = [recognizer locationInView:recognizer.view];
        CGRect zoomToRect = CGRectMake(0, 0, 50, 50);
        zoomToRect.origin = CGPointMake(location.x - CGRectGetWidth(zoomToRect)/2, location.y - CGRectGetHeight(zoomToRect)/2);
        [self zoomToRect:zoomToRect animated:YES];
    }
}

#pragma mark - Notification

- (void)orientationChanged:(NSNotification *)notification
{
    self.rotating = YES;
}

#pragma mark - Helper

- (void)setMaxMinZoomScale
{
    CGSize imageSize = self.imageView.image.size;
    CGSize imagePresentationSize = self.imageView.contentSize;
    CGFloat maxScale = MAX(imageSize.height / imagePresentationSize.height, imageSize.width / imagePresentationSize.width);
    self.maximumZoomScale = MAX(1, maxScale); // Should not less than 1
    self.minimumZoomScale = 1.0;
}

- (void)centerContent
{
    CGRect frame = self.containerView.frame;
    
    CGFloat top = 0, left = 0;
    if (self.contentSize.width < self.bounds.size.width) {
        left = (self.bounds.size.width - self.contentSize.width) * 0.5f;
    }
    if (self.contentSize.height < self.bounds.size.height) {
        top = (self.bounds.size.height - self.contentSize.height) * 0.5f;
    }
    
    top -= frame.origin.y;
    left -= frame.origin.x;
    
    self.contentInset = UIEdgeInsetsMake(top, left, top, left);
}

@end
