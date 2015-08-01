//
//  MXAppDelegate.h
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface MXAppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>
@property (strong,nonatomic) UIWindow *window;
@end
