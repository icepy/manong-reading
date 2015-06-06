//
//  GStaticDataSource.h
//  manongweekly
//
//  Created by xiangwenwen on 15/4/20.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *MANDownloadPath = @"https://github.com/lcepy/manong/blob/master/README.md"; //远程地址
static NSString *MANOriginReadmeName = @"readme.html"; //存储在本地的原始文件
static NSString *MANConfigFileName = @"manongconfig.plist"; //配置文件名


#define MANNAVHEIGHT 64
#define MANSCREENWIDTH          ([UIScreen mainScreen].bounds.size.width)
#define MANSCREENHEIGHT         ([UIScreen mainScreen].bounds.size.height)


#define MANREAD                 ([UIColor colorWithWhite:0.702 alpha:1.000])
#define MANNOTREAD              ([UIColor colorWithWhite:0.200 alpha:1.000])