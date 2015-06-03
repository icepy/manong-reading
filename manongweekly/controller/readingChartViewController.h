//
//  readingChartViewController.h
//  manongweekly
//
//  Created by xiangwenwen on 15/6/3.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class modelManager;

@interface readingChartViewController : UIViewController

@property(strong, nonatomic) modelManager *manager;
@property (copy, nonatomic) NSString *readingChartTitle;

@end
