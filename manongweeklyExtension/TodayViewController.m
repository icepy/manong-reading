//
//  TodayViewController.m
//  manongweeklyExtension
//
//  Created by xiangwenwen on 15/6/2.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TodayMNCellTableViewCell.h"

@interface TodayViewController () <NCWidgetProviding,UITableViewDataSource,UITableViewDelegate>

@property(strong,nonatomic) NSUserDefaults *userDefaults;
@property(weak, nonatomic) IBOutlet UITableView *extensionTable;
@property(strong, nonatomic) NSMutableArray *dataSource;



@end

@implementation TodayViewController

-(NSUserDefaults *)userDefaults
{
    if (!_userDefaults) {
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.manongweeklySharedDefaults"];
    }
    return _userDefaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //{{20, 8}, {280, 104}}
    
    self.extensionTable.dataSource = self;
    self.extensionTable.delegate = self;
    self.dataSource = [self.userDefaults objectForKey:@"wen.manongweekly.MANTagDataSource"];
    if (!self.dataSource || !self.dataSource.count) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.bounds.size.width,35)];
        label.text = @"暂无数据";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14.0];
        [self.view addSubview:label];
        self.extensionTable.hidden = YES;
    }
    
}

-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsMake(0, 25, 15, 0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, (33*self.dataSource.count)+33);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ManTagExtension";
    TodayMNCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.ladderDataSource = self.dataSource[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tagData =  self.dataSource[indexPath.row];
    NSString *hostApp = tagData[@"tagName"];
    NSString *openUrl = [NSString stringWithFormat:@"wenIcepy://%@",hostApp];
    [self.extensionContext openURL:[NSURL URLWithString:openUrl] completionHandler:^(BOOL success) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
