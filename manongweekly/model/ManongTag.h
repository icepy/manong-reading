//
//  ManongTag.h
//  manongweekly
//
//  Created by xiangwenwen on 15/5/9.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ManongTag : NSManagedObject

@property (nonatomic, retain) NSNumber * contentCount;
@property (nonatomic, retain) NSString * tagKey;
@property (nonatomic, retain) NSString * tagName;

@end
