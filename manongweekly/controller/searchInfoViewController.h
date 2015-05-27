//
//  searchInfoViewController.h
//  manongweekly
//
//  Created by xiangwenwen on 15/4/28.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class modelManager;

@interface searchInfoViewController : UIViewController

@property (strong,nonatomic) modelManager *manager;
@property (strong,nonatomic) UIWebView *webPageView;

@end
