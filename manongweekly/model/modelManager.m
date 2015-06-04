//
//  modelManager.m
//  manongweekly
//
//  Created by xiangwenwen on 15/4/20.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//


#import "modelManager.h"
#import "ManongTag.h"
#import "ManongTitle.h"
#import "ManongContent.h"
#import "ManongDigest.h"
#import "HTMLStringParse.h"


NSInteger manongTagAZSorted(id obj1,id obj2,void *context)
{
    ManongTag *mntag1 = (ManongTag *)obj1;
    ManongTag *mntag2 = (ManongTag *)obj2;
    return [mntag1.tagName localizedCompare:mntag2.tagName];
}

NSInteger manongContentAZSorted(id obj1,id obj2,void *context)
{
    ManongContent *mncontent1 = (ManongContent *)obj1;
    ManongContent *mncontent2 = (ManongContent *)obj2;
    return [mncontent1.wkName localizedCompare:mncontent2.wkName];
}

@interface modelManager()

@property(strong,nonatomic) NSFileManager *managerFile;
@property(strong,nonatomic) NSManagedObjectContext *context;
@property(strong,nonatomic) HTMLStringParse *htmlParse;
@property(strong,nonatomic) NSDateFormatter *formatter;


@end

@implementation modelManager

-(NSDateFormatter *)formatter
{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"YYYY年M月dd日 HH时mm分"];
    }
    return _formatter;
}

-(NSFileManager *)managerFile{
    if (!_managerFile) {
        _managerFile = [[NSFileManager alloc] init];
    }
    return _managerFile;
}

-(NSManagedObjectContext *)context
{
    if (!_context) {
        NSError *error = nil;
        //创建db url
        NSString *dbPath = [self.baseDoc stringByAppendingPathComponent:@"manong.db"];
        NSURL *dbUrl = [NSURL fileURLWithPath:dbPath];
        //创建模型托管对象
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        //创建持久化存储调度器
        NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        //v1.2 core data 升级 （简单的增加些许字段）
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbUrl options:options error:&error];
        //创建上下文
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:store];
    }
    return _context;
}

-(NSString *)baseDoc
{
    if (!_baseDoc) {
        _baseDoc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    }
    return _baseDoc;
}

-(NSString *)libraryCaches
{
    if (!_libraryCaches) {
        _libraryCaches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    }
    return _libraryCaches;
}

//当前的时间
-(NSString *)createDateNowString:(NSDate *)date
{
    NSString *nowTime = [self.formatter stringFromDate:date];
    return nowTime;
}

//历史时间
-(NSString *)createDateHistoryString:(int64_t)timeId
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeId/1000.0];
    NSString *historyTime = [self.formatter stringFromDate:date];
    return historyTime;
    
}

-(NSDictionary *)configFile
{
    NSString *filePath = [self.baseDoc stringByAppendingPathComponent:MANConfigFileName];
    BOOL isFile = [self.managerFile fileExistsAtPath:filePath];
    if (!isFile) {
        [self.managerFile createFileAtPath:filePath contents:nil attributes:nil];
    }
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return config ? config : @{};
}

-(void)readConfig:(configHandler)confighandler
{
    NSDictionary *config = [self configFile];
    confighandler(config);
}

-(BOOL)writeConfig:(NSDictionary *)config
{
    NSString *filePath = [self.baseDoc stringByAppendingPathComponent:MANConfigFileName];
    BOOL isWrite = [config writeToFile:filePath atomically:YES];
    return isWrite;
}

-(void)writeAllDataForSQLite:(NSData *)data handlerCallback:(writeDB)writehandler
{
    self.htmlParse = [[HTMLStringParse alloc] initWithContentParse:data];
    NSDictionary *modelData = [self.htmlParse manongTitleIndexHash];
    NSArray *indexKey = modelData.allKeys;
    
    for (NSString *tagKey in indexKey) {
        [self saveForSQLite:tagKey content:modelData[tagKey]];
    }
    
    NSError *error = nil;
    BOOL success;
    [self.context save:&error];
    success = error ? NO : YES;
    if (success) {
        [self fetchAllManongTag];
    }
    writehandler(success,error);
}

-(void)saveForSQLite:(NSString *)tagKey content:(NSMutableArray *)contentData
{
    NSRange nameRange = [tagKey rangeOfString:@"user-content-"];
    NSString *tagNmae = [tagKey substringFromIndex:nameRange.length];
    
    if (![tagNmae isEqualToString:@"索引"]) {
        NSEntityDescription *mnTag = [NSEntityDescription entityForName:@"ManongTag" inManagedObjectContext:self.context];
        ManongTag *manongTag = [[ManongTag alloc] initWithEntity:mnTag insertIntoManagedObjectContext:self.context];
        manongTag.tagKey = tagKey;
        manongTag.tagName = tagNmae;
        
        NSEntityDescription *mnTitle = [NSEntityDescription entityForName:@"ManongTitle" inManagedObjectContext:self.context];
        ManongTitle *manongTitle = [[ManongTitle alloc] initWithEntity:mnTitle insertIntoManagedObjectContext:self.context];
        manongTitle.tagKey = tagKey;
        manongTitle.tagName = tagNmae;
        manongTitle.tagStatus = @NO;
        
        NSMutableSet *contentSet = [[NSMutableSet alloc] init];
        for (NSDictionary *content in contentData) {
            NSLog(@"%@",content[@"wkName"]);
            NSEntityDescription *mnContent = [NSEntityDescription entityForName:@"ManongContent" inManagedObjectContext:self.context];
            ManongContent *manongContent = [[ManongContent alloc] initWithEntity:mnContent insertIntoManagedObjectContext:self.context];
            manongContent.wkName = content[@"wkName"];
            manongContent.wkUrl = content[@"wkUrl"];
            manongContent.wkStatus = @NO;
            manongContent.wkContrsationKey = tagKey;
            manongContent.wkCount = @0;
            [contentSet addObject:manongContent];
        }
        [manongTitle addMnwwContent:contentSet];
        manongTag.contentCount = @(contentSet.count);
    }
}

-(void)fetchAllManongDigest
{
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ManongDigest"];
    NSArray *arr = [self.context executeFetchRequest:request error:&error];
    if (!error) {
        NSMutableArray *digest = self.dataSource[0];
        [digest removeAllObjects];
        if (arr.count) {
            [digest setArray:arr];
        }
    }
}

-(BOOL)saveDigest:(ManongTag *)rmmnDigest manongDigest:(ManongTag *)mnDigest isRemove:(BOOL)isRemove
{
    NSEntityDescription *mndigest = [NSEntityDescription entityForName:@"ManongDigest" inManagedObjectContext:self.context];
    ManongDigest *manongDigest = [[ManongDigest alloc] initWithEntity:mndigest insertIntoManagedObjectContext:self.context];
    manongDigest.tagKey = mnDigest.tagKey;
    manongDigest.tagName = mnDigest.tagName;
    if(isRemove){
        if (rmmnDigest) {
            //删除，再添加
            id manongdigest = [self fetchManong:@"ManongDigest" fetchKey:@"tagKey" fetchValue:rmmnDigest.tagKey];
            if (manongdigest) {
                manongdigest = (ManongDigest *)manongdigest;
                [self.context deleteObject:manongdigest];
            }
        }
    }
    return [self saveData];
}

-(BOOL)saveData
{
    NSError *error = nil;
    [self.context save:&error];
    if (error) {
        return NO;
    }else{
        return YES;
    }
}

-(BOOL)isChinese:(NSString *)value
{
    __block BOOL isChinese = NO;
    NSArray *strArray = [value componentsSeparatedByString:@""];
    [strArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        unichar ch = [value characterAtIndex:idx];
        if (0x4e00 < ch  && ch < 0x9fff)
        {
            isChinese = YES;
            *stop = YES;
        }
    }];
    return isChinese;
}

-(BOOL)isZHCN
{
    NSUserDefaults *defs =  [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defs objectForKey:@"AppleLanguages"];
    NSString *lag = languages[0];
    if ([lag isEqualToString:@"zh-Hans"]) {
        return YES;
    }else{
        return NO;
    }
}

-(void)fetchAllManongTag
{
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ManongTag"];
    NSArray *arr =  [self.context executeFetchRequest:request error:&error];
    __weak modelManager *weakSelf = self;
    if (!error) {
        NSMutableArray *tagArr = self.dataSource[1];
        [tagArr removeAllObjects];
        NSArray *arrSorted =  [arr sortedArrayUsingFunction:manongTagAZSorted context:NULL];
        if ([self isZHCN]) {
            NSArray *arrSorteds = [arrSorted sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                ManongTag *mntag1 = (ManongTag *)obj1;
                ManongTag *mntag2 = (ManongTag *)obj2;
                return [weakSelf isChinese:mntag1.tagName] || [weakSelf isChinese:mntag2.tagName];
            }];
            [tagArr setArray:arrSorteds];
        }else{
            [tagArr setArray:arrSorted];
        }
        [tagArr removeObjectAtIndex:0];
        [self fetchAllManongDigest];
    }
}

-(NSArray *)fetchAllManongContent:(NSString *)tagToInfoParameter
{
    ManongTitle *manongTitle = (ManongTitle *) [self fetchManong:@"ManongTitle" fetchKey:@"tagKey" fetchValue:tagToInfoParameter];
    NSSet *contentSet =  manongTitle.mnwwContent;
    NSMutableArray *data = [[NSMutableArray alloc] init];
    for (ManongContent *mnContent in contentSet) {
        [data addObject:mnContent];
    }
    NSArray *AZData = [data sortedArrayUsingFunction:manongContentAZSorted context:NULL];
    NSArray *result = [AZData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        ManongContent *content1 = (ManongContent *)obj1;
        ManongContent *content2 = (ManongContent *)obj2;
        if (![content1.wkStatus intValue]) {
            return YES;
        }
        if(![content2.wkStatus intValue]){
            return NO;
        }
        NSDate *date1 = content1.wkTime;
        NSDate *date2 = content2.wkTime;
        return date1.timeIntervalSinceNow < date2.timeIntervalSinceNow;
    }];
    return result;
}

-(id)fetchManong:(NSString *)tag fetchKey:(NSString *)key fetchValue:(NSString *)value
{
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:tag];
    NSPredicate *dicate = [NSPredicate predicateWithFormat:@"%K CONTAINS %@",key,value];
    [request setPredicate:dicate];
    NSArray *arr = [self.context executeFetchRequest:request error:&error];
    if (!error) {
        if (arr.count) {
            id manong = arr[0];
            return manong;
        }
        return nil;
    }
    return nil;
}

-(NSArray *)vagueSearchToMN:(NSDictionary *)searchInfo
{
    /*
     *  searchKey  搜索的关键字
     *  searchType 搜索时表的名字
     *  searchAttributes 搜索时的索引名
     */
    NSError *error = nil;
    NSString *type = searchInfo[@"searchType"];
    NSString *attributes = searchInfo[@"searchAttributes"];
    NSString *key = searchInfo[@"searchKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:type];
    NSPredicate *dicate = nil;
    if ([type isEqualToString:@"ManongTag"]) {
        dicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@",attributes,key];
    }else{
//        key = [self removeSpaceAndNewline:key];
        dicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",attributes,key];
    }
    
    [request setPredicate:dicate];
    NSArray *arr = [self.context executeFetchRequest:request error:&error];
    if (!error) {
        return arr;
    }
    return nil;
}

-(void)updateDataSourceForSQLite:(NSData *)data handlerCallback:(updateDB)updatehandler
{
    self.htmlParse = [[HTMLStringParse alloc] initWithContentParse:data];
    NSDictionary *modelData = [self.htmlParse manongTitleIndexHash];
    NSArray *indexKey = modelData.allKeys;
    for (NSString *tagKey in indexKey) {
        [self updateForSQLite:tagKey content:modelData[tagKey]];
    }
    
    NSError *error = nil;
    BOOL success;
    [self.context save:&error];
    success = error ? NO : YES;
    if (success) {
        [self fetchAllManongTag];
    }
    updatehandler(success,error);
}

-(void)updateForSQLite:(NSString *)tagKey content:(NSMutableArray *)contentData
{
    //搜索key
    NSRange nameRange = [tagKey rangeOfString:@"user-content-"];
    //标签名
    NSString *tagNmae = [tagKey substringFromIndex:nameRange.length];
    //先查询ManongTag 如果没有，更新ManongTag和ManongTitle 还有ManongContent循环
    ManongTag *isMnTag =  [self fetchManong:@"ManongTag" fetchKey:@"tagName" fetchValue:tagNmae];
    if (![tagNmae isEqualToString:@"索引"]) {
        //索引不存在
        if (!isMnTag) {
            NSEntityDescription *mnTag = [NSEntityDescription entityForName:@"ManongTag" inManagedObjectContext:self.context];
            ManongTag *manongTag = [[ManongTag alloc] initWithEntity:mnTag insertIntoManagedObjectContext:self.context];
            manongTag.tagKey = tagKey;
            manongTag.tagName = tagNmae;
            
            NSEntityDescription *mnTitle = [NSEntityDescription entityForName:@"ManongTitle" inManagedObjectContext:self.context];
            ManongTitle *manongTitle = [[ManongTitle alloc] initWithEntity:mnTitle insertIntoManagedObjectContext:self.context];
            manongTitle.tagKey = tagKey;
            manongTitle.tagName = tagNmae;
            manongTitle.tagStatus = @NO;
            
            NSMutableSet *contentSet = [[NSMutableSet alloc] init];
            for (NSDictionary *content in contentData) {
                NSEntityDescription *mnContent = [NSEntityDescription entityForName:@"ManongContent" inManagedObjectContext:self.context];
                ManongContent *manongContent = [[ManongContent alloc] initWithEntity:mnContent insertIntoManagedObjectContext:self.context];
                manongContent.wkName = content[@"wkName"];
                manongContent.wkUrl = content[@"wkUrl"];
                manongContent.wkStatus = @NO;
                manongContent.wkContrsationKey = tagKey;
                manongContent.wkCount = @0;
                [contentSet addObject:manongContent];
            }
            [manongTitle addMnwwContent:contentSet];
            manongTag.contentCount = @(contentSet.count);
        }else{
            //tag存在并且contentData的数据大于Tag中记录的contentCount，开始检索相应ManongContent每一条数据
            if (contentData.count > [isMnTag.contentCount integerValue]) {
                for (NSDictionary *content in contentData) {
                    //查询ManongContent
                    ManongContent *isMnContent =  [self fetchManong:@"ManongContent" fetchKey:@"wkName" fetchValue:content[@"wkName"]];
                    //如果为nil，说明不存在，新增一条记录
                    if (!isMnContent) {
                        NSEntityDescription *mnContent = [NSEntityDescription entityForName:@"ManongContent" inManagedObjectContext:self.context];
                        ManongContent *manongContent = [[ManongContent alloc] initWithEntity:mnContent insertIntoManagedObjectContext:self.context];
                        manongContent.wkName = content[@"wkName"];
                        manongContent.wkUrl = content[@"wkUrl"];
                        manongContent.wkStatus = @NO;
                        manongContent.wkContrsationKey = tagKey;
                        manongContent.wkCount = @0;
                    }
                }
            }
        }
    }
}

- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

-(BOOL)isBlankString:(NSString *)string
{
    if (string == nil) {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }    
    return NO;
}

-(void)dealloc
{
    NSLog(@"model manager  销毁");
}
@end