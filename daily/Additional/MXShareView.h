//
//  MXShareView.h
//  daily
//
//  Created by mufeng on 15/8/1.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXShareModel.h"

@interface MXShareView : UIView
+ (instancetype)initWithFrame:(CGRect)frame andModel:(MXShareModel *)model;
- (instancetype)initWithFrame:(CGRect)frame andModel:(MXShareModel *)model;
- (void)show;
@end