//
//  MXMainView.m
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXMainView.h"
#import "MXCollectionModel.h"

@implementation MXMainView

-(id)initWithFrame:(CGRect)frame stuff:(NSMutableArray *)collections{
    self = [super initWithFrame:frame];
    
    if(self){
        self.collections = collections;
        self.positions = [[NSMutableArray alloc] init];
        
        for(int i=0; i<self.collections.count; i++){
            [self.positions addObject:@"0"];
        }
        
        [self setupInitView];
    }
    
    return self;
}

-(void)setupInitView {
    UICollectionViewFlowLayout *flow =[[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = CGSizeMake(ScreenWidth, ScreenHeight);
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:flow];
    view.delegate = self;
    view.dataSource = self;
    view.backgroundColor = [UIColor clearColor];
    view.pagingEnabled = YES;
    view.showsHorizontalScrollIndicator = NO;
    [view registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"maincell"];
    [self addSubview:view];
}

#pragma mark - UICollectionViewDataSource Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collections.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"maincell" forIndexPath:indexPath];
    
    self.index = (int)indexPath.row;
    int index = [[self.positions objectAtIndex:self.index] intValue];
    
    MXCollectionModel *collection = [self.collections objectAtIndex:self.index];
    MXPostView *postView = [[MXPostView alloc] initWithFrame:CGRectMake(0,0,ScreenWidth,ScreenHeight)
                                                       stuff:collection
                                           lastScrollToIndex:index
                                                    delegate:self];
    
    [cell.contentView addSubview:postView];
    
    return cell;
}

#pragma mark - MXPostView Delegate
- (void)postView:(MXPostView *)postView didScrollToIndex:(int)index{
    [self.positions replaceObjectAtIndex:self.index withObject:[NSString stringWithFormat:@"%d", index]];
}

@end
