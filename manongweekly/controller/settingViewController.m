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

@interface settingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingTable;
@property (strong, nonatomic) NSArray *dataSource;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *showLoading;
@property (weak, nonatomic) IBOutlet UIView *showShade;
@end

@implementation settingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = @[@[@"应用介绍与反馈"],@[@"更新分类"],@[@"清除缓存"]];
    self.navigationItem.title = @"设置";
    self.settingTable.dataSource = self;
    self.settingTable.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backIndexView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section > 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.section = indexPath.section;
    }
    cell.MNSettingInfo = self.dataSource[indexPath.section][indexPath.row];
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
   NSString *tag =  self.dataSource[indexPath.section][indexPath.row];
    if ([tag isEqualToString:@"应用介绍与反馈"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        referralPageViewController *referral = [storyboard instantiateViewControllerWithIdentifier:@"referralPage"];
        referral.referraTitle = tag;
        [self.navigationController pushViewController:referral animated:YES];
    }else{
        if ([tag isEqualToString:@"更新分类"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFetchGithubManongData" object:nil];
        }else{
            if ([tag isEqualToString:@"清除缓存"]) {
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
