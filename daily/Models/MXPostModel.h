//
//  MXPostModel.h
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXPostModel : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *excerpt;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *avatar;
@property int count;
@end
