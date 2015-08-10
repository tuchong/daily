//
//  MXCollectionModel.h
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXPostModel;

@interface MXCollectionModel : NSObject
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) MXPostModel *post;
@property int index;
@end