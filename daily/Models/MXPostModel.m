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
    return @{@"authorName": @"author.name",
             @"authorUrl": @"author.url",
             @"avatar": @"author.icon",
             @"count": @"image_count"
             };
}
@end
