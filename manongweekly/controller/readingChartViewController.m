//
//  readingChartViewController.m
//  manongweekly
//
//  Created by xiangwenwen on 15/6/3.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "readingChartViewController.h"
#import <Masonry/Masonry.h>
#import <PNChart/PNChart.h>

@interface readingChartViewController()<UIGestureRecognizerDelegate>

@end

@implementation readingChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.readingChartTitle;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackImage"] style:UIBarButtonItemStylePlain target:self action:@selector(backForSetting)];
    self.navigationItem.leftBarButtonItem = back;
}

-(void)backForSetting{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
