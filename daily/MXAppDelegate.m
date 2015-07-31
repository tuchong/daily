//
//  MXAppDelegate.m
//  daily
//
//  Created by mufeng on 15/7/30.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "MXAppDelegate.h"
#import "MXRootViewController.h"

@implementation MXAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = RGBA(0x4444444,1);
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [[MXRootViewController alloc] init];
    
    //Light status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}

@end
