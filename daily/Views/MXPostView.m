//
//  MXPostView.m
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXPostView.h"
#import "MXPostViewCell.h"

@implementation MXPostView

-(instancetype)initWithFrame:(CGRect)frame stuff:(MXCollectionModel *)model lastScrollToIndex:(NSInteger)index delegate:(id<MXPostViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    
    if(self){
        self.delegate = delegate;
        self.collection = model;
        self.index = index;
        
        [self setupInitView];
    }
    
    return self;
}

-(void)setupInitView {
    UICollectionViewFlowLayout *flow =[[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = CGSizeMake(ScreenWidth, ScreenHeight);
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:flow];
    view.delegate = self;
    view.dataSource = self;
    view.pagingEnabled = YES;
    view.contentOffset = CGPointMake(0,self.index*ScreenHeight);
    view.bounces = YES;
    view.scrollsToTop = YES;
    view.showsVerticalScrollIndicator = NO;
    view.backgroundColor = RGBA(0x4444444,1);
    [view registerClass:[MXPostViewCell class] forCellWithReuseIdentifier:@"postcell"];
    
    [self addSubview:view];
}

#pragma mark - UICollectionViewDataSource Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collection.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MXPostViewCell *cell = (MXPostViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"postcell" forIndexPath:indexPath];
    
    [cell setWithCollection:self.collection forIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(postView:didScrollToIndex:)]) {
        [self.delegate postView:self didScrollToIndex:indexPath.row];
    }
    
    return cell;
}

@end
