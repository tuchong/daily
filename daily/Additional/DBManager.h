//
//  DBManager.h
//  daily
//
//  Created by mufeng on 15/8/20.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject
+ (DBManager *)shareManager;
- (void)insertArray:(NSArray *)collections;
- (NSArray *)selectWithPage:(NSInteger)page prePageNumber:(NSInteger)number;
- (NSInteger)count;
@end
