//
//  MXImageModel.h
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXImageModel : NSObject
@property (strong, nonatomic) NSString *excerpt;
@property (strong, nonatomic) NSString *camera;
@property (strong, nonatomic) NSString *lens;
@property (strong, nonatomic) NSString *exposure;
@property (strong, nonatomic) NSString *uri;
@property bool status;
@end