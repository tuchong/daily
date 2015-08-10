//
//  MXRootViewController.m
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXRootViewController.h"
#import "AFNetworking.h"
#import "Masonry.h"
#import "MXMainView.h"
#import "MXCollectionModel.h"

@interface MXRootViewController ()
@property (retain,nonatomic,readwrite) MXMainView *mainView;
@end

@implementation MXRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMainView];
    [self setupHeaderView];
    [self pullFromCache];
    [self pullFromUrl];
}

- (void)setupMainView {
    self.mainView = [MXMainView new];
    [self.view addSubview:self.mainView];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
        make.size.equalTo(self.view);
    }];
}

- (void)setupHeaderView {
    UIView *containerView = [UIView new];
    [self.view addSubview:containerView];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(@(30));
        make.height.mas_equalTo(@(30));
    }];
    
    UIImageView *logoView = [UIImageView new];
    [containerView addSubview:logoView];
    logoView.image = IMG(@"icon-30.png");
    
    UILabel *titleView = [UILabel new];
    [containerView addSubview:titleView];
    
    titleView.text = NSLocalizedString(@"title", nil);
    titleView.textColor = RGBA(0xffffff,1);
    titleView.font = [UIFont systemFontOfSize:20];
    titleView.shadowColor = RGBA(0x666666,.5);
    titleView.shadowOffset = CGSizeMake(0,1);
    
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView);
        make.top.equalTo(containerView);
        make.right.mas_equalTo(titleView.mas_left).offset(-5);
        make.width.and.height.mas_equalTo(@(30));
    }];
    
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView);
        make.top.equalTo(containerView);
        make.left.mas_equalTo(logoView.mas_right).offset(5);
        make.height.equalTo(containerView);
    }];
}

- (void)pullFromCache {
    NSArray *cache = [self getCache];
    
    if (cache!=nil) {
        NSArray *collections = [MXCollectionModel objectArrayWithKeyValuesArray:cache];
        [self.mainView stuff:collections];
    }
}

- (void)pullFromUrl {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:MXTuchongDailyToken forHTTPHeaderField:MXTuchongDailyTokenKey];
    [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [manager GET:MXTuchongDailyApiUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSArray *responseArray = [responseObject objectForKey:@"collections"];
        NSArray *cache = [self getCache];
        
        if(cache==nil || ![responseArray isEqualToArray:cache]){
            NSArray *collections = [MXCollectionModel objectArrayWithKeyValuesArray:responseArray];
            [self setCache:responseArray];
            [self.mainView stuff:collections];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"%@", error);
    }];
}

- (NSArray *)getCache {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *data = (NSData *)[prefs dataForKey:MXTuchongDailyCacheKey];
    NSArray *array;
    
    if(data!=nil){
        array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return array;
}

- (void)setCache:(NSArray *)array {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:data forKey:MXTuchongDailyCacheKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end