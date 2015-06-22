//
//  MNNetworking.m
//  manongweekly
//
//  Created by xiangwenwen on 15/6/22.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "MNNetworking.h"




@interface MNNetworking()

@property(strong,nonatomic) NSMutableURLRequest *MNNRequest;
@property(strong,nonatomic) NSURLSessionTask *MNNTask;
@property(copy,nonatomic) NSURL *MNNUrl;
@property(copy,nonatomic) NSString *MNNMethod;
@property(strong,nonatomic) NSDictionary *MNNParameters;
@property(strong,nonatomic) NSDictionary *MNNHeaders;
@property(assign,nonatomic) NSTimeInterval MNNTimeout;
@property(assign,nonatomic) NSURLRequestCachePolicy MNNRPolicy;

@end

@implementation MNNetworking

-(instancetype)initWithRequest:(NSString *)URL method:(NSString *)HttpMethod parame:(NSDictionary *)parames head:(NSDictionary *)heade timeout:(NSTimeInterval)timeout policy:(NSURLRequestCachePolicy)policy
{
    self = [super init];
    if (self) {
        self.MNNUrl = [NSURL URLWithString:URL];
        self.MNNMethod = HttpMethod;
        self.MNNParameters = parames;
        self.MNNHeaders = heade;
        self.MNNTimeout = timeout;
        self.MNNRPolicy = policy;
        [self MNNCreateRequestObje];
    }
    return self;
}

-(void)MNNCreateRequestObje
{
    if ([self.MNNMethod isEqualToString:@"GET"]) {
        
    }
    self.MNNRequest = [[NSMutableURLRequest alloc] initWithURL:self.MNNUrl cachePolicy:self.MNNRPolicy timeoutInterval:self.MNNTimeout];
    self.MNNRequest.HTTPMethod = self.MNNMethod;
    
    if (![self.MNNMethod isEqualToString:@"GET"]) {
        
    }
    
}

+(instancetype)request:(NSString *)URL method:(NSString *)HttpMethod
{
    MNNetworking *MNNW = [[MNNetworking alloc] initWithRequest:URL method:HttpMethod parame:nil head:nil timeout:8 policy:NSURLRequestReloadIgnoringCacheData];
    return MNNW;
}

-(void)MNNFire:(NetworkingHandler)successHandler error:(NetworkingError)errorHandler
{
    
}

@end
