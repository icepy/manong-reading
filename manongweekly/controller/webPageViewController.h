//
//  webPageViewController.h
//  manongweekly
//
//  Created by xiangwenwen on 15/4/20.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface webPageViewController : UIViewController

@property(strong,nonatomic) NSURL *requestURL;
@property(copy,nonatomic) NSString *requestTitle;

@end
