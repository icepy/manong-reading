//
//  ManongTitle.h
//  manongweekly
//
//  Created by xiangwenwen on 15/5/9.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ManongContent;

@interface ManongTitle : NSManagedObject

@property (nonatomic, retain) NSString * tagKey;
@property (nonatomic, retain) NSString * tagName;
@property (nonatomic, retain) NSNumber * tagStatus;
@property (nonatomic, retain) NSSet *mnwwContent;
@end

@interface ManongTitle (CoreDataGeneratedAccessors)

- (void)addMnwwContentObject:(ManongContent *)value;
- (void)removeMnwwContentObject:(ManongContent *)value;
- (void)addMnwwContent:(NSSet *)values;
- (void)removeMnwwContent:(NSSet *)values;

@end
