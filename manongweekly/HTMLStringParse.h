//
//  HTMLStringParse.h
//  manongweekly
//
//  Created by xiangwenwen on 15/4/20.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"

@interface HTMLStringParse : NSObject

/**
 *  待分析的内容字符串
 *
 *  @param data <#data description#>
 *
 *  @return <#return value description#>
 */
-(instancetype)initWithContentParse:(NSData *)data;

-(NSDictionary *)manongTitleIndexHash;

-(NSString *)manongCRSFID;

@end
