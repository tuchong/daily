//
//  MXShareView.h
//  daily
//
//  Created by mufeng on 15/8/1.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXCollectionModel.h"

@interface MXShareView : UIView
+ (instancetype)initWithFrame:(CGRect)frame andCollection:(MXCollectionModel *)model;
- (instancetype)initWithFrame:(CGRect)frame andCollection:(MXCollectionModel *)model;
- (void)show;
@end