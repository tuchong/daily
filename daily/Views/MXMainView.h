//
//  MXMainView.h
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXPostView.h"

@interface MXMainView : UIView<MXPostViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate>

@property (retain,nonatomic,readwrite) NSMutableArray *collections;
-(void)stuff:(NSMutableArray *)collections;
@property (retain,nonatomic,readwrite) NSMutableArray *positions;
@property (retain,nonatomic,readwrite) UICollectionView *collectionView;
@property int index;
@end