//
//  MXPostViewCell.h
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXCollectionModel.h"
#import "MXLoaderView.h"

@interface MXPostViewCell : UICollectionViewCell<UIGestureRecognizerDelegate>
@property (retain,nonatomic,readwrite) UIImageView *imageView;
@property (retain,nonatomic,readwrite) UILabel *titleView;
@property (retain,nonatomic,readwrite) UILabel *pagedView;
@property (retain,nonatomic,readwrite) UILabel *nameView;
@property (retain,nonatomic,readwrite) UILabel *caremaView;
@property (retain,nonatomic,readwrite) UIImageView *avatarView;
@property (retain,nonatomic,readwrite) MXLoaderView *loaderView;
@property (retain,nonatomic,readwrite) MXCollectionModel *collection;
-(void)setWithCollection:(MXCollectionModel *)collection forIndexPath:(NSIndexPath *)indexPath;
@end