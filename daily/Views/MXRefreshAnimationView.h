//
//  MXRefreshAnimationView.h
//  daily
//
//  Created by mufeng on 15/8/22.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ANGLE(a) 2*M_PI/360*a

@interface MXRefreshAnimationView : UIView
@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, strong) NSTimer *timer;
-(void)drawPath:(CGFloat)rate;
- (void)startRotateAnimation;
- (void)stopRotateAnimation;
@end
