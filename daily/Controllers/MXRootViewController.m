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
@property (retain,nonatomic,readwrite) UIImageView *screenView;
@property (retain,nonatomic,readwrite) MXMainView *mainView;
@end

@implementation MXRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMainView];
    [self setupScreenView];
    [self setupHeaderView];
    [self pullData];
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

- (void)setupScreenView {
    self.screenView = [UIImageView new];
    self.screenView.layer.masksToBounds = YES;
    self.screenView.contentMode = UIViewContentModeScaleAspectFill;
    self.screenView.alpha = 0.5;
    [self.view addSubview:self.screenView];
    
    [self.screenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.edges.equalTo(self.view);
    }];
    
    self.screenView.image = IMG(@"screen.jpg");
}

- (void)boarding {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:6];
    self.screenView.transform = CGAffineTransformMakeScale(1.8,1.8);
    self.screenView.alpha = 1;
    [UIView commitAnimations];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)pullData {
    [self boarding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:MXTuchongDailyToken forHTTPHeaderField:@"tuchong-daily-token"];
    [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [manager GET:MXTuchongDailyApiUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSMutableArray *collections = [MXCollectionModel objectArrayWithKeyValuesArray:[responseObject objectForKey:@"collections"]];
        
        [self.mainView stuff:collections];
        [self.screenView.layer removeAllAnimations];
        
        [UIView animateWithDuration:1 animations:^{
            self.screenView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.screenView removeFromSuperview];
            self.screenView = nil;
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end