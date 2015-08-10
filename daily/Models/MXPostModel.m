//
//  MXPostModel.m
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXPostModel.h"

@implementation MXPostModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"author" : @"author.name",
             @"avatar" : @"author.icon",
             @"count" : @"image_count"
             };
}
@end
