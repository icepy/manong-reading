//
//  MNNetworking.h
//  manongweekly
//
//  Created by xiangwenwen on 15/6/22.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NetworkingHandler)(NSData *data,NSURLResponse *response);
typedef void(^NetworkingError)(NSError *error);

@interface MNNetworking : NSObject

-(instancetype)initWithRequest:(NSString *)URL method:(NSString *)HttpMethod parame:(NSDictionary *)parames head:(NSDictionary *)heade timeout:(NSTimeInterval)timeout policy:(NSURLRequestCachePolicy)policy;
+(instancetype)request:(NSString *)URL method:(NSString *)HttpMethod;

-(void)MNNFire:(NetworkingHandler)successHandler error:(NetworkingError)errorHandler;

@end
