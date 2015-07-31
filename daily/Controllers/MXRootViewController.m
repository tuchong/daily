//
//  MXRootViewController.m
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXRootViewController.h"
#import "MXLoaderView.h"
#import "AFNetworking.h"
#import "Masonry.h"
#import "MXMainView.h"
#import "MXCollectionModel.h"

@interface MXRootViewController ()
@property (retain,nonatomic,readwrite) MXLoaderView *loaderView;
@end

@implementation MXRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupHeaderView];
    [self setupLoaderView];
    [self pullData];
}

- (void)setupMainView:(NSMutableArray *)collections {
    MXMainView *mainView = [[MXMainView alloc] initWithFrame:CGRectMake(0,0,ScreenWidth,ScreenHeight) stuff:collections];
    [self.view addSubview:mainView];
    [self.view sendSubviewToBack:mainView];
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

- (void)setupLoaderView {
    self.loaderView = [MXLoaderView new];
    [self.view addSubview:self.loaderView];
    
    [self.loaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.edges.equalTo(self.view);
    }];
}

- (void)pullData {
    [self.loaderView show];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:MXTuchongDailyToken forHTTPHeaderField:@"tuchong-daily-token"];
    [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [manager GET:MXTuchongDailyApiUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *collections = [MXCollectionModel objectArrayWithKeyValuesArray:[responseObject objectForKey:@"collections"]];
        
        [self.loaderView dismiss];
        [self setupMainView:collections];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end