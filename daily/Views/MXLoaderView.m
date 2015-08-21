//
//  MXLoaderView.m
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXLoaderView.h"
#import "MXIndefiniteAnimatedView.h"

@interface MXLoaderView ()
@property (retain,nonatomic,readwrite) MXIndefiniteAnimatedView *animatedView;
@end

@implementation MXLoaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = RGBA(0x000000,.3);
        self.alpha = 0;
        self.animatedView = [[MXIndefiniteAnimatedView alloc] initWithFrame:(CGRect){(ScreenWidth-24)/2,(ScreenHeight-24)/2,24,24}];
        [self addSubview:self.animatedView];
    }
    
    return self;
}

- (void)show {
    [self setAlpha:1];
    [self.animatedView startRotateAnimation];
    [self.superview bringSubviewToFront:self];
}

- (void)dismiss {
    [self setAlpha:0];
    [self.animatedView stopRotateAnimation];
    [self.superview sendSubviewToBack:self];
}

@end
