//
//  MXRootViewController.m
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXRootViewController.h"
#import "AFNetworking.h"
#import "DBManager.h"
#import "Masonry.h"
#import "MXPostView.h"
#import "MXCollectionModel.h"
#import "MXRefreshAnimationView.h"

@interface MXRootViewController ()<MXPostViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (retain,nonatomic,readwrite) UIView *headerView;
@property (retain,nonatomic,readwrite) MXRefreshAnimationView *loaderView;
@property (retain,nonatomic,readwrite) NSMutableArray *positions;
@property (retain,nonatomic,readwrite) UICollectionView *collectionView;
@property (retain,nonatomic,readwrite) NSMutableArray *collections;
@property (assign,nonatomic,readwrite) NSInteger index;
@property (assign,nonatomic,readwrite) NSInteger page;
@property (assign,nonatomic,readwrite) NSInteger maxPage;
@property (assign,nonatomic,readwrite) BOOL syning;
@end

@implementation MXRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupInitialData];
    [self pullCache];
    [self setupView];
    [self syncRemote:^{}];
}

- (void)setupView{
    [self setupLoaderView];
    [self setupMainView];
    [self setupHeaderView];
}

- (void)setupLoaderView{
    self.loaderView = [[MXRefreshAnimationView alloc] initWithFrame:CGRectMake(0,(ScreenHeight-24)/2,24,24)];
    [self.view addSubview:self.loaderView];
}

- (void)setupMainView {
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
    self.collectionView.scrollsToTop = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"maincell"];
    
    [self.view addSubview:self.collectionView];
}

- (void)setupHeaderView {
    self.headerView = [UIView new];
    self.headerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.headerView];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(@(30));
        make.height.mas_equalTo(@(30));
    }];
    
    UIImageView *logoView = [UIImageView new];
    [self.headerView addSubview:logoView];
    logoView.image = IMG(@"icon-30");
    
    UILabel *titleView = [UILabel new];
    [self.headerView addSubview:titleView];
    
    titleView.text = NSLocalizedString(@"title", nil);
    titleView.textColor = RGBA(0xffffff,1);
    titleView.font = [UIFont systemFontOfSize:20];
    titleView.shadowColor = RGBA(0x666666,.5);
    titleView.shadowOffset = CGSizeMake(0,1);
    
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView);
        make.top.equalTo(self.headerView);
        make.right.mas_equalTo(titleView.mas_left).offset(-5);
        make.width.and.height.mas_equalTo(@(30));
    }];
    
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headerView);
        make.top.equalTo(self.headerView);
        make.left.mas_equalTo(logoView.mas_right).offset(5);
        make.height.equalTo(self.headerView);
    }];
}

- (void)setupInitialData {
    self.positions = [[NSMutableArray alloc] init];
    
    for(int i=0; i<10; i++){
        [self.positions addObject:[NSNumber numberWithInt:0]];
    }
    
    self.index = 0;
    self.page = 1;
    self.maxPage =([[DBManager shareManager] count]+10-1)/10;
}

- (void)pullCache {
    NSArray *cache = [[DBManager shareManager] selectWithPage:self.page prePageNumber:10];
    
    self.collections = [MXCollectionModel objectArrayWithKeyValuesArray:cache];
}

- (void)syncRemote:(void (^)())block {
    if(self.syning){
        return;
    }
    
    self.syning = TRUE;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:MXTuchongDailyToken forHTTPHeaderField:MXTuchongDailyTokenKey];
    [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [manager GET:MXTuchongDailyApiUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.syning = FALSE;
        [[DBManager shareManager] insertArray:[responseObject objectForKey:@"collections"]];
        [self setupInitialData];
        [self pullCache];
        [self.collectionView reloadData];
        
        block();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.syning = FALSE;
        block();
        
        NSLog(@"%@", error);
    }];
}

#pragma mark - UICollectionViewDataSource Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collections.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"maincell" forIndexPath:indexPath];
    
    if( self.positions.count ){
        self.index = indexPath.row;
        NSUInteger index = [[self.positions objectAtIndex:self.index] intValue];
        
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
- (void)postView:(MXPostView *)postView didScrollToIndex:(NSInteger)index{
    [self.positions replaceObjectAtIndex:self.index withObject:[NSString stringWithFormat:@"%ld", (long)index]];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.x < -50){
        [self.loaderView startRotateAnimation];
        [self syncRemote:^{
            [self.loaderView stopRotateAnimation];
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.x + scrollView.frame.size.width*2 >= scrollView.contentSize.width) {
        if(self.page < self.maxPage){
            NSMutableArray *tmpPositions = [[NSMutableArray alloc] init];
            for(long i=0; i<10; i++){
                [tmpPositions addObject:[NSNumber numberWithInt:0]];
            }
            
            [self.positions addObjectsFromArray:tmpPositions];
            self.page++;
            
            NSArray *cache = [[DBManager shareManager] selectWithPage:self.page prePageNumber:10];
            NSArray *tmpPosts = [MXCollectionModel objectArrayWithKeyValuesArray:cache];
            [self.collections addObjectsFromArray:tmpPosts];
            
            [self.collectionView reloadData];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.x<0 && !self.syning){
        CGFloat rate = fabs(scrollView.contentOffset.x/50);
        
        [self.loaderView drawPath:rate];
    }
}

#pragma mark - NSNotificationCenter destroy
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end