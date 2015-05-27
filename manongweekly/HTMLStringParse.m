//
//  HTMLStringParse.m
//  manongweekly
//
//  Created by xiangwenwen on 15/4/20.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "HTMLStringParse.h"

@interface HTMLStringParse()

@property(strong,nonatomic) TFHpple *doc;
@property(strong,nonatomic) NSMutableDictionary *indexHash;

@end

@implementation HTMLStringParse

-(instancetype)initWithContentParse:(NSData *)data
{
    self = [super init];
    if (self) {
        self.indexHash = [[NSMutableDictionary alloc] init];
        self.doc = [[TFHpple alloc] initWithData:data isXML:NO];
    }
    return self;
}

-(NSDictionary *)manongTitleIndexHash
{
    NSArray *arr = [self.doc searchWithXPathQuery:@"//article[@class='markdown-body entry-content']/p"];
    NSString *tempTagTitle = @"user-content-索引";
    [self.indexHash setObject:[[NSMutableArray alloc] init] forKey:tempTagTitle];
    for (TFHppleElement *elem in arr) {
        NSString *tagTitle = elem.firstChild.attributes[@"name"];
        if ([tagTitle isEqualToString:@"user-content-IOS"]) {
            tagTitle = @"user-content-iOS";
        }
        if ([tagTitle isEqualToString:@"user-content-SWIFT"]) {
            tagTitle = @"user-content-Swift";
        }
        if (!tagTitle) {
            NSArray *child = elem.children;
            for (TFHppleElement *childNode in child) {
                
                if (!childNode.text || [childNode.text isEqualToString:@"原地址"] ||[childNode.text isEqualToString:@"http://weekly.manong.io/"]) {
                    continue;
                }
                
                if ([childNode.tagName isEqualToString:@"a"]) {
                    NSMutableArray *obj = [self.indexHash objectForKey:tempTagTitle];
                    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                    //转码
                    NSString *wkOriginUrl = childNode.attributes[@"href"];
                    NSString *wkName = [childNode.text stringByRemovingPercentEncoding];
                    if (wkName && wkOriginUrl) {
                        NSArray *urlArr = [wkOriginUrl componentsSeparatedByString:@"url="];
                        [data setObject:wkOriginUrl forKeyedSubscript:@"wkUrl"];
                        NSLog(@"wkName----%@",wkName);
                        [data setObject:wkName forKey:@"wkName"];
                        if (urlArr.count == 2) {
                            NSString *url = [urlArr[1] stringByRemovingPercentEncoding];
                            [data setObject:url forKey:@"wkOriginUrl"];
                        }else{
                            [data setObject:urlArr[0] forKey:@"wkOriginUrl"];
                        }
                        [obj addObject:data];
                    }
                    
                }
                continue;
            }
        }else{
            tempTagTitle = [tagTitle stringByRemovingPercentEncoding];
            [self.indexHash setObject:[[NSMutableArray alloc] init] forKey:tempTagTitle];
        }
    }
    
    return self.indexHash;
}

@end
