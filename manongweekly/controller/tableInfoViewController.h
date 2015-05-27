//
//  tableInfoViewController.h
//  manongweekly
//
//  Created by xiangwenwen on 15/4/20.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class modelManager;

@interface tableInfoViewController : UIViewController

@property(copy,nonatomic) NSString *tagToInfoParameter;
@property(strong,nonatomic) modelManager *manager;

@end
