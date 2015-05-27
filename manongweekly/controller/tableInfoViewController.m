//
//  tableInfoViewController.m
//  manongweekly
//
//  Created by xiangwenwen on 15/4/20.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "tableInfoViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "modelManager.h"
#import "MNContentCell.h"
#import "ManongTitle.h"
#import "ManongContent.h"
#import "webPageViewController.h"

@interface tableInfoViewController()<UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) NSMutableArray *dataSource;
@property (strong,nonatomic) NSIndexPath *updateIndexPath;
@property (weak, nonatomic) IBOutlet UITableView *contentCategoryTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *tableInfoLoading;

@end

@implementation tableInfoViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"table view controller Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));
    __weak tableInfoViewController *weakSelf = self;
    self.contentCategoryTable.dataSource = self;
    self.tableInfoLoading.hidden = NO;
    self.contentCategoryTable.hidden = YES;
    self.navigationItem.title = self.tagToInfoParameter;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *arr = [weakSelf.manager fetchAllManongContent:weakSelf.tagToInfoParameter];
        weakSelf.dataSource = [[NSMutableArray alloc] initWithArray:arr];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.tableInfoLoading.hidden = YES;
            weakSelf.contentCategoryTable.hidden = NO;
            [weakSelf.contentCategoryTable reloadData];
        });
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.contentCategoryTable && self.updateIndexPath) {
        NSArray *arr = @[self.updateIndexPath];
        [self.contentCategoryTable reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MNContentsCell" forIndexPath:indexPath];
    cell.manongContent = self.dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSLog(@"%@",NSStringFromCGRect(cell.frame));
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak tableInfoViewController *weakSelf = self;
    return [tableView fd_heightForCellWithIdentifier:@"MNContentsCell" configuration:^(MNContentCell *cell) {
        cell.manongContent = weakSelf.dataSource[indexPath.row];
    }];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"table view controller Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));
    if ([segue.identifier isEqualToString:@"gotoWebPage"]) {
        
        UINavigationController *navC = (UINavigationController *)segue.destinationViewController;
        webPageViewController *webPage = (webPageViewController *)navC.topViewController;
        self.updateIndexPath = [self.contentCategoryTable indexPathForSelectedRow];
        ManongContent *content = self.dataSource[self.updateIndexPath.row];
        NSDate *date = [NSDate date];
        NSString *readTime = [self.manager createDateNowString:date];
        ManongContent *mncontent = [self.manager fetchManong:@"ManongContent" fetchKey:@"wkName" fetchValue:content.wkName];
        if (mncontent) {
            mncontent.wkTime = date;
            mncontent.wkStringTime = readTime;
            mncontent.wkStatus = @YES;
            content.wkTime = date;
            content.wkStringTime = readTime;
            content.wkStatus = @YES;
            [self.manager saveData];
        }
        NSURL *url = [NSURL URLWithString:content.wkUrl];
        webPage.requestURL = url;
        webPage.requestTitle = content.wkName;
    }
}

-(void)dealloc
{
    NSLog(@"table info view controller 销毁");
}

@end
