//
//  DBManager.m
//  daily
//
//  Created by mufeng on 15/8/20.
//  Copyright (c) 2015年 misery.io. All rights reserved.
//

#import "DBManager.h"
#import "FMDatabase.h"

@interface DBManager()
@property (retain,nonatomic,readwrite) FMDatabase *db;
@property (retain,nonatomic,readwrite) NSString *dbPath;
@end

@implementation DBManager

+ (DBManager *)shareManager{
    static DBManager *manager =nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (manager==nil) {
            manager =[[DBManager alloc]init];
        }
    });
    
    return manager;
}

- (id)init{
    self =[super init];
    
    if (self) {
        //_lock = [[NSLock alloc] init];
        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.dbPath = [documentsPath stringByAppendingPathComponent:@"daily.sqlite3"];
        self.db = [FMDatabase databaseWithPath:self.dbPath];
            
        if( [self.db open] ){
            NSString *sql = @"CREATE TABLE IF NOT EXISTS 'posts' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'postid' varchar(125), 'content' text)";
            
            BOOL success = [self.db executeUpdate:sql];
            
            if (!success) {
                NSLog(@"%@",self.db.lastError);
            }
        }else{
            NSLog(@"error when open db");
        }
    }
    
    return self;
}

- (void)insertArray:(NSArray *)collections{
    if( [self.db open] ){
        for (long i=collections.count-1; i>=0; i--) {
            [self insertDictionary:[collections objectAtIndex:i]];
        }
        
        [self.db close];
    }
}

- (void)insertDictionary:(NSDictionary *)post{
    //[_lock lock];
    if( [self.db open] ){
        NSString *postId = [post objectForKey:@"postId"];
        
        FMResultSet *s = [self.db executeQuery:[NSString stringWithFormat:@"SELECT * FROM posts WHERE postid = %@ LIMIT 1", postId]];
        
        if (![s next]) {
            NSString *insertSql = @"insert into posts(postid, content) values(?, ?)";
            
            NSError * error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:post options:0 error:&error];
            
            if (error) {
                NSLog(@"ERROR, faild to get json data");
                //[_lock unlock];
                
                return;
            }
            
            NSString *content = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
            BOOL success = [self.db executeUpdate:insertSql, postId, content];
            if (!success) {
                NSLog(@"insert error:%@", self.db.lastError);
            }
        }
    }else{
        NSLog(@"error when open db");
    }
    
    //[_lock unlock];
}

- (NSArray *)selectWithPage:(NSInteger)page prePageNumber:(NSInteger)number{
    NSMutableArray *collections = [[NSMutableArray alloc] init];
    
    if( [self.db open] ){
        NSString *sql = [NSString stringWithFormat:@"select content from posts order by id desc limit %d,%ld", (page-1)*number, (long)number];
        FMResultSet *rs = [self.db executeQuery:sql];
        
        while ([rs next]) {
            NSString *content = [rs stringForColumn:@"content"];
            
            NSError *error;
            NSData *objectData = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *post = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
            
            [collections addObject:post];
        }
        
        [self.db close];
    }
    
    return collections;
}

- (NSInteger)count{
    NSInteger cnt = 0;
    if( [self.db open] ){
        NSString *sql = @"select count(content) as count from posts";
        FMResultSet *rs = [self.db executeQuery:sql];
        
        while ([rs next]) {
            cnt = [[rs stringForColumn:@"count"] integerValue];
        }
        
        [self.db close];
    }
    
    return cnt;
}

@end
