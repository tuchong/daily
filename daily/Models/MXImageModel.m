//
//  MXImageModel.m
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXImageModel.h"

@implementation MXImageModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"camera" : @"exif.camera.name",
             @"lens" : @"exif.lens.name",
             @"exposure" : @"exif.exposure"
             };
}
@end
