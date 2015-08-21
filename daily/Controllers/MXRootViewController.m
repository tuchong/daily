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

@interface MXRootViewController ()<MXPostViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (retain,nonatomic,readwrite) UIView *headerView;
@property (retain,nonatomic,readwrite) NSMutableArray *positions;
@property (retain,nonatomic,readwrite) UICollectionView *collectionView;
@property (retain,nonatomic,readwrite) NSMutableArray *collections;
@property (assign,nonatomic,readwrite) NSInteger index;
@property (assign,nonatomic,readwrite) NSInteger page;
@property (assign,nonatomic,readwrite) NSInteger maxPage;
@end

@implementation MXRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNotification];
    [self setupInitialData];
    [self pullCache];
    [self setupView];
    [self syncRemote];
}

- (void)setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncRemote) name:@"EnterForegroundNotification" object:nil];
}

- (void)setupView{
    [self setupMainView];
    [self setupHeaderView];
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

- (void)syncRemote {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:MXTuchongDailyToken forHTTPHeaderField:MXTuchongDailyTokenKey];
    [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [manager GET:MXTuchongDailyApiUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [[DBManager shareManager] insertArray:[responseObject objectForKey:@"collections"]];
        [self setupInitialData];
        [self pullCache];
        [self.collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.page < self.maxPage){
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        
        float x = offset.x + bounds.size.width - inset.right;
        float w = size.width;
        
        if(x > w - bounds.size.width) {
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

#pragma mark - NSNotificationCenter destroy
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end