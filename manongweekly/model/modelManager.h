//
//  modelManager.h
//  manongweekly
//
//  Created by xiangwenwen on 15/4/20.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GStaticDataSource.h"

typedef void(^configHandler)(NSDictionary *config);
typedef void(^writeDB)(BOOL success,NSError *error);
typedef void(^updateDB)(BOOL success,NSError *error);

@class ManongTag;

@interface modelManager : NSObject

@property(strong,nonatomic) NSMutableArray *dataSource;
@property(copy,nonatomic) NSString *baseDoc;
@property(copy,nonatomic) NSString *libraryCaches;

-(void)readConfig:(configHandler)confighandler;

-(void)writeAllDataForSQLite:(NSData *)data handlerCallback:(writeDB)writehandler;

-(BOOL)writeConfig:(NSDictionary *)config;

-(void)fetchAllManongTag;

-(NSArray *)fetchAllManongContent:(NSString *)tagToInfoParameter;

-(id)fetchManong:(NSString *)tag fetchKey:(NSString *)key fetchValue:(NSString *)value;

-(BOOL)saveDigest:(ManongTag *)rmmnDigest manongDigest:(ManongTag *)mnDigest isRemove:(BOOL)isRemove;

-(NSString *)createDateNowString:(NSDate *)date;

-(BOOL)saveData;

-(NSArray *)vagueSearchToMN:(NSDictionary *)searchInfo;

-(void)updateDataSourceForSQLite:(NSData *)data handlerCallback:(updateDB)updatehandler;

-(BOOL)isBlankString:(NSString *)string;

@end
