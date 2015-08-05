//
//  MXPostViewCell.m
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXPostViewCell.h"
#import "Masonry.h"
#import "MXPostModel.h"
#import "MXImageModel.h"
#import "VIPhotoView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MXPostViewCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.frame = (CGRect){0, 0, ScreenWidth, ScreenHeight};
        //self.backgroundColor = RGBA(0x4444,1);
        
        self.imageView = [UIImageView new];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self.contentView);
            make.edges.equalTo(self.contentView);
        }];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0,ScreenHeight-100,ScreenWidth,100);
        [self.imageView.layer addSublayer:gradientLayer];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                      (__bridge id)RGBA(0x000000,0.8).CGColor];
        gradientLayer.locations = @[@(0.0f) ,@(1.0f)];
        
        self.avatarView = [UIImageView new];
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = 20;
        [self.contentView addSubview:self.avatarView];
        
        self.titleView = [UILabel new];
        self.titleView.font = [UIFont systemFontOfSize:14];
        self.titleView.textColor = [UIColor whiteColor];
        self.titleView.shadowColor = RGBA(0x666666,.5);
        self.titleView.shadowOffset = CGSizeMake(0,1);
        [self.contentView addSubview:self.titleView];
        
        self.nameView = [UILabel new];
        self.nameView.font = [UIFont systemFontOfSize:13];
        self.nameView.textColor = [UIColor whiteColor];
        self.nameView.shadowColor = RGBA(0x666666,.5);
        self.nameView.shadowOffset = CGSizeMake(0,1);
        [self.contentView addSubview:self.nameView];
        
        self.caremaView = [UILabel new];
        self.caremaView.font = [UIFont systemFontOfSize:13];
        self.caremaView.textColor = [UIColor whiteColor];
        self.caremaView.shadowColor = RGBA(0x666666,.5);
        self.caremaView.shadowOffset = CGSizeMake(0,1);
        [self.contentView addSubview:self.caremaView];
        
        self.pagedView = [UILabel new];
        self.pagedView.font = [UIFont systemFontOfSize:15];
        self.pagedView.textColor = [UIColor whiteColor];
        self.pagedView.shadowColor = RGBA(0x666666,.5);
        self.pagedView.shadowOffset = CGSizeMake(0,1);
        self.pagedView.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.pagedView];
        
        
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.right.equalTo(self.contentView).offset(-16);
            make.bottom.mas_equalTo(self.avatarView.mas_top).offset(-10);
        }];
        
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(@(40));
            make.left.equalTo(self.contentView).offset(16);
            make.bottom.equalTo(self.contentView).offset(-12);
        }];
        
        [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatarView.mas_right).offset(5);
            make.right.mas_equalTo(self.pagedView.mas_left);
            make.bottom.mas_equalTo(self.caremaView.mas_top);
            make.height.mas_equalTo(20);
        }];

        [self.caremaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.nameView);
            make.bottom.equalTo(self.contentView).offset(-12);
            make.height.mas_equalTo(20);
        }];
        
        [self.pagedView mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.width.mas_equalTo(@(50));
            make.height.mas_equalTo(@(16));
            make.left.mas_equalTo(self.caremaView.mas_right);
            make.right.equalTo(self.contentView).offset(-16);
            make.bottom.equalTo(self.contentView).offset(-16);
        }];
        
        
        self.loaderView = [MXLoaderView new];
        [self.contentView addSubview:self.loaderView];
        
        [self.loaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self.contentView);
            make.edges.equalTo(self.contentView);
        }];
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        singleTapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapGesture];
    }
    
    return self;
}

-(void)setWithCollection:(MXCollectionModel *)collection forIndexPath:(NSIndexPath *)indexPath{
    MXImageModel *imageModel = [collection.images objectAtIndex:indexPath.row];
    
    self.pagedView.text = [NSString stringWithFormat:@"%d/%d", (int)indexPath.row+1, collection.post.count];
    
    [self.loaderView show];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.jpg", imageModel.uri]]
                      placeholderImage:nil
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 [self.loaderView dismiss];
                                 self.imageView.image = image;
                             }];
    
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", collection.post.avatar]]];
    
    self.titleView.text = collection.post.title;
    self.nameView.text = collection.post.author;
    self.caremaView.text = imageModel.camera;
}

#pragma mark -- Double tap
- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    [VIPhotoView initWithFrame:self.bounds andImage:self.imageView.image];
}

@end
