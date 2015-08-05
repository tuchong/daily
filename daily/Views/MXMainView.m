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

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        self.positions = [[NSMutableArray alloc] init];
        [self setupInitView];
    }
    
    return self;
}

-(void)stuff:(NSArray *)collections{
    self.collections = collections;
    
    for(int i=0; i<self.collections.count; i++){
        [self.positions addObject:@"0"];
    }
    
    [self.collectionView reloadData];
}

-(void)setupInitView {
    UICollectionViewFlowLayout *flow =[[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = CGSizeMake(ScreenWidth, ScreenHeight);
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:flow];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"maincell"];
    [self addSubview:self.collectionView];
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

    if( self.positions.count ){
        self.index = (int)indexPath.row;
        int index = [[self.positions objectAtIndex:self.index] intValue];
        
        MXCollectionModel *collection = [self.collections objectAtIndex:self.index];
        
        MXPostView *tmpView = (MXPostView *)[cell.contentView viewWithTag:911];
        [tmpView removeFromSuperview];
        tmpView = nil;
        
        MXPostView *postView = [[MXPostView alloc] initWithFrame:CGRectMake(0,0,ScreenWidth,ScreenHeight)
                                                           stuff:collection
                                               lastScrollToIndex:index
                                                        delegate:self];
        [postView setTag:911];
        [cell.contentView addSubview:postView];
    }
    
    return cell;
}

#pragma mark - MXPostView Delegate
- (void)postView:(MXPostView *)postView didScrollToIndex:(int)index{
    [self.positions replaceObjectAtIndex:self.index withObject:[NSString stringWithFormat:@"%d", index]];
}

@end
