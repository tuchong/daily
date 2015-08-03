//
//  MXShareView.m
//  daily
//
//  Created by mufeng on 15/8/1.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXShareView.h"
#import "MXPostModel.h"
#import "MXImageModel.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "MXShareModel.h"

@interface MXShareView ()
@property (nonatomic, strong) UIView *darkView;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) MXCollectionModel *collection;
@end

@class MXWechat;

@implementation MXShareView

+ (instancetype)initWithFrame:(CGRect)frame andCollection:(MXCollectionModel *)model{
    return [[self alloc] initWithFrame:(CGRect)frame andCollection:(MXCollectionModel *)model];
}

- (instancetype)initWithFrame:(CGRect)frame andCollection:(MXCollectionModel *)model{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.collection = model;
        
        self.darkView = [[UIView alloc] initWithFrame:frame];
        self.darkView.backgroundColor = [UIColor blackColor];
        self.darkView.alpha = 0;
        [self addSubview:self.darkView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [self.darkView addGestureRecognizer:tapGesture];
        
        self.controlView = [[UIView alloc] initWithFrame:CGRectMake(0,frame.size.height,frame.size.width,220)];
        self.controlView.backgroundColor = RGBA(0xf0f0f0,1);
        [self addSubview:self.controlView];
        
        UILabel *titleView = [[UILabel alloc] init];
        titleView.text = NSLocalizedString(@"sharetitle", nil);
        titleView.textColor = RGBA(0x777777,1);
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.font = [UIFont systemFontOfSize:15.f];
        titleView.frame = CGRectMake(0,0,frame.size.width,50.f);
        [self.controlView addSubview:titleView];
        
        NSArray *btnArray = @[@{@"icon": @"WeChat", @"title": NSLocalizedString(@"WeChat", nil)},@{@"icon": @"WeChat_Moment", @"title": NSLocalizedString(@"WeChat Monments", nil)},@{@"icon": @"WeChat_Favorite", @"title": NSLocalizedString(@"WeChat Favorites", nil)},@{@"icon": @"Weibo", @"title": NSLocalizedString(@"Weibo", nil)}];
        
        float spaceWidth = (frame.size.width-20*2-57*4)/3;
        int index = 0;
        
        for(NSDictionary *dict in btnArray){
            UIView *sview = [[UIView alloc] initWithFrame:CGRectMake(20+index*(57+spaceWidth),55,57,90)];
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,57,57)];
            [btn setTag:index];
            [btn setBackgroundImage:IMG([dict objectForKey:@"icon"]) forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(tapShareBtn:) forControlEvents:UIControlEventTouchUpInside];
            [sview addSubview:btn];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,57,57,33)];
            title.font = [UIFont systemFontOfSize:11];
            title.text = [dict objectForKey:@"title"];
            title.textAlignment = NSTextAlignmentCenter;
            title.textColor = RGBA(0x999999,1);
            [sview addSubview:title];
        
            [self.controlView addSubview:sview];
            index++;
        }
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20,160,frame.size.width-40,40)];
        [cancelBtn setBackgroundColor:[UIColor whiteColor]];
        [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [[cancelBtn titleLabel] setFont:[UIFont systemFontOfSize:14.0f]];
        [cancelBtn setTitleColor:RGBA(0x777777,1) forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(dismissByCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.layer.cornerRadius = 5.f;
        cancelBtn.layer.masksToBounds = YES;
        [self.controlView addSubview:cancelBtn];
        
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow addSubview:self];
    }
    
    return self;
}

- (void)show {
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.darkView setAlpha:0.4f];
                         [self.darkView setUserInteractionEnabled:YES];
                         
                         CGRect frame = self.controlView.frame;
                         frame.origin.y -= frame.size.height;
                         [self.controlView setFrame:frame];
                     }
                     completion:nil];
}

- (void)tapShareBtn:(UIButton *)btn{
    MXShareModel *mxshare = [[MXShareModel alloc] init];
    
    mxshare.title = [NSString stringWithFormat:@"%@ @%@", self.collection.post.title, self.collection.post.author];
    mxshare.url = self.collection.post.url;
    mxshare.excerpt = self.collection.post.excerpt;
    
    if(btn.tag < 3){
        mxshare.scene = btn.tag;
        
        if( self.collection.images.count ){
            MXImageModel *imageModel = self.collection.images[0];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@.jpg", imageModel.uriSmall]];
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
            mxshare.image = image;
        }
        
        [self shareToWechat:mxshare];
    }else{
        if( self.collection.images.count ){
            MXImageModel *imageModel = self.collection.images[0];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@.jpg", imageModel.uriSmall]];
            mxshare.imageData = [NSData dataWithContentsOfURL:url];
        }
        
        [self shareToWeibo:mxshare];
    }
    
    [self removeView];
}

- (void)dismissByCancelBtn {
    [self removeView];
}

- (void)dismiss:(UITapGestureRecognizer *)recognizer{
    [self removeView];
}

- (void)removeView {
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.darkView setAlpha:0];
                         [self.darkView setUserInteractionEnabled:NO];
                         
                         CGRect frame = self.controlView.frame;
                         frame.origin.y += frame.size.height;
                         [self.controlView setFrame:frame];
                     }
                     completion:^(BOOL finished) {
                         self.controlView.hidden = YES;
                         [self removeFromSuperview];
                     }];
}

#pragma mark - Wechat api
- (void)shareToWechat:(MXShareModel *)mxshare
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = mxshare.title;
    message.description = mxshare.excerpt;
    [message setThumbImage:mxshare.image];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = mxshare.url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = (int)mxshare.scene;
    
    [WXApi sendReq:req];
}

#pragma mark - Weibo api
- (void)shareToWeibo:(MXShareModel *)mxshare
{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.scope = @"all";
    
    WBMessageObject *message = [WBMessageObject message];
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"mxweibo";
    webpage.title = mxshare.title;
    webpage.description = mxshare.excerpt;
    webpage.thumbnailData = mxshare.imageData;
    webpage.webpageUrl = mxshare.url;
    
    message.text = mxshare.title;
    message.mediaObject = webpage;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
    [WeiboSDK sendRequest:request];
}

@end
