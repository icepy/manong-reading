//
//  settingViewController.m
//  manongweekly
//
//  Created by xiangwenwen on 15/5/8.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "settingViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MNSettingCell.h"
#import "referralPageViewController.h"
#import "readingChartViewController.h"


@interface settingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingTable;
@property (strong, nonatomic) NSArray *dataSource;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *showLoading;
@property (weak, nonatomic) IBOutlet UIView *showShade;
@property (strong, nonatomic) NSDictionary *identifierMap;
@property (strong, nonatomic) UISwitch *dknightSwitchView;

@end

@implementation settingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.dataSource = @[@[@"阅读图表统计",@"应用介绍与反馈",@"更新推送"],@[@"更新分类"],@[@"清除缓存"]];
    
    self.dataSource = @[
                        @[
                            @{
                                @"setName":@"阅读图表统计",
                                @"setIcon":@"RankFillImage"
                                },
                            @{
                                @"setName":@"应用介绍与反馈",
                                @"setIcon":@"ProtocolReadImage"
                                }
                            ],
                        @[
                            @{
                                @"setName":@"更新分类",
                                @"setIcon":@"UpdateTagImage"
                                },
                            @{
                                @"setName":@"清除缓存",
                                @"setIcon":@"ClearCacheImage"
                                }
                            ]
                        ];
    
    self.navigationItem.title = @"设置";
    self.settingTable.dataSource = self;
    self.settingTable.delegate = self;
    self.identifierMap = @{
                           @"阅读图表统计":@"readingChart",
                           @"应用介绍与反馈":@"referralPage"
                           };
//    self.dknightSwitchView = [[UISwitch alloc] initWithFrame:CGRectZero];
//    [self.dknightSwitchView addTarget:self action:@selector(toNightChange) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backIndexView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)toNightChange{}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MNSettingCell" forIndexPath:indexPath];
    cell.section = indexPath.section;
    cell.MNSettingInfo = self.dataSource[indexPath.section][indexPath.row];
//    if ([cell.MNSettingInfo[@"setName"] isEqualToString:@"更新推送"]) {
//        cell.accessoryView = self.dknightSwitchView;
//        cell.imageView.image = [UIImage imageNamed:@"RankFillImage"];
//    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak settingViewController *weakSelf = self;
    return [tableView fd_heightForCellWithIdentifier:@"MNSettingCell" configuration:^(MNSettingCell *cell) {
        cell.MNSettingInfo = weakSelf.dataSource[indexPath.section][indexPath.row];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellInfo =  self.dataSource[indexPath.section][indexPath.row];
    NSString *tag = cellInfo[@"setName"];
    
    if (!self.identifierMap[tag]) {
        if([tag isEqualToString:@"更新分类"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFetchGithubManongData" object:nil];
        }else{
            if([tag isEqualToString:@"清除缓存"]){
                self.showLoading.hidden = NO;
                self.showShade.hidden = NO;
                NSString *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                NSFileManager *manager = [[NSFileManager alloc] init];
                NSArray *files = [manager subpathsAtPath:cache];
                __weak settingViewController *weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    for (NSString *filePath in files) {
                        NSError *error = nil;
                        NSString *fileP = [cache stringByAppendingPathComponent:filePath];
                        NSFileManager *fileManager = [[NSFileManager alloc] init];
                        if ([fileManager fileExistsAtPath:fileP]) {
                            [fileManager removeItemAtPath:fileP error:&error];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kRemoveCacheSuccess" object:nil];
                    });
                });
            }
        }
    }else{
        
        NSString *identifier = self.identifierMap[tag];
        if ([identifier isEqualToString:@"referralPage"]) {
            referralPageViewController *referral = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            referral.referraTitle = tag;
            [self.navigationController pushViewController:referral animated:YES];
        }else if ([identifier isEqualToString:@"readingChart"]){
            readingChartViewController *readChart = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            readChart.readingChartTitle = tag;
            readChart.manager = self.manager;
            [self.navigationController pushViewController:readChart animated:YES];
        }
    }
    
}

-(void)dealloc
{
    NSLog(@"setting view controller 释放");
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
