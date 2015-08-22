//
//  MXRefreshAnimationView.m
//  daily
//
//  Created by mufeng on 15/8/22.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXRefreshAnimationView.h"

@implementation MXRefreshAnimationView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

-(void)drawPath:(CGFloat)rate{
    self.rate = rate<0 ? 0 : (rate>1 ? 1: rate);
    self.frame = CGRectMake((50-24)*rate/2,(ScreenHeight-24)/2,24,24);
    
    [self setNeedsDisplay];
}

- (void)startRotateAnimation{
    [self.superview bringSubviewToFront:self];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0);
    animation.toValue = @(2*M_PI);
    animation.duration = 1.f;
    animation.repeatCount = INT_MAX;
    
    [self.layer addAnimation:animation forKey:@"keyFrameAnimation"];
}

- (void)stopRotateAnimation{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.layer removeAllAnimations];
        self.alpha = 1;
        [self.superview sendSubviewToBack:self];
    }];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineWidth = .5f;
    UIColor *lineColor = RGBA(0x666666, .5);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextAddArc(context,10, 11,10-lineWidth,ANGLE(120), ANGLE(120)+ANGLE(330)*self.rate,0);
    CGContextStrokePath(context);
    
    CGFloat lineWidth2 = 1.f;
    UIColor *lineColor2 = [UIColor whiteColor];
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor2.CGColor);
    CGContextAddArc(context,10, 10,10-lineWidth2,ANGLE(120), ANGLE(120)+ANGLE(330)*self.rate,0);
    CGContextStrokePath(context);
}

@end
