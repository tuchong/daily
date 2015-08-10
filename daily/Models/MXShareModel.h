//
//  MXShareModel.h
//  daily
//
//  Created by mufeng on 15/8/4.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXShareModel : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *excerpt;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSData *imageData;
@property NSInteger scene;
@end
