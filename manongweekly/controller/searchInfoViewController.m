//
//  searchInfoViewController.m
//  manongweekly
//
//  Created by xiangwenwen on 15/4/28.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "UITableView+FDTemplateLayoutCell.h"
#import "searchInfoViewController.h"
#import "webPageViewController.h"
#import "modelManager.h"
#import "MNSearchInfoCell.h"
#import "ManongContent.h"

@interface searchInfoViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *exeSearchBar; //搜索
@property (weak, nonatomic) IBOutlet UILabel *showErrorMessage; //错误消息
@property (weak, nonatomic) IBOutlet UITableView *showSearchInfoTable; //table
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchLoading;
@property (strong,nonatomic) NSMutableArray *searchDataSource; //原数据（Table真实使用）
@property (assign,nonatomic) NSInteger currentSelected;
@property (assign,nonatomic) BOOL isUseSearchSuccess;
@property (assign,nonatomic) BOOL isSearchSelected;
@property (assign,nonatomic) BOOL isSearchBlock;
@property (copy, nonatomic) NSString *searchText;
@property (assign, nonatomic) BOOL isFirstResponder;

@end

@implementation searchInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchDataSource = [[NSMutableArray alloc] init];
    self.exeSearchBar.showsScopeBar = NO;
    self.isFirstResponder = NO;
    self.exeSearchBar.selectedScopeButtonIndex = 1;
    self.currentSelected = 0;
    self.exeSearchBar.delegate = self;
    self.showSearchInfoTable.hidden = YES;
    self.showSearchInfoTable.dataSource = self;
    self.showSearchInfoTable.delegate = self;
    self.navigationItem.title = @"搜索";
    self.showErrorMessage.numberOfLines = 0;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    __weak searchInfoViewController *weakSelf = self;
    if (!self.isFirstResponder) {
        self.isFirstResponder = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.6 animations:^{
                [weakSelf.exeSearchBar becomeFirstResponder];
            }];
        });
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchDataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNSearchInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MNSearchInfoCell" forIndexPath:indexPath];
    cell.manongC = self.searchDataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak searchInfoViewController *weakSelf = self;
    return [tableView fd_heightForCellWithIdentifier:@"MNSearchInfoCell" configuration:^(id cell) {
        MNSearchInfoCell *searchCell = cell;
        searchCell.manongC = weakSelf.searchDataSource[indexPath.row];
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@",searchBar.text);
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    if ([self.manager isBlankString:searchBar.text]) {
        NSString *emptyErrorInfo = [NSString stringWithFormat:@"匹配您对\"%@\"的搜索，没有项目在您的列表中",searchBar.text];
        self.showSearchInfoTable.hidden = YES;
        self.showErrorMessage.text = emptyErrorInfo;
        self.showErrorMessage.hidden = NO;
        return;
    }
    if (!self.isSearchBlock) {
        //上锁
        self.isSearchBlock = YES;
        self.searchLoading.hidden = NO;
        self.showSearchInfoTable.contentOffset = CGPointMake(0, 0);
        //table 隐藏并且加载
        self.showSearchInfoTable.hidden = YES;
        self.showErrorMessage.text = @"";
        self.showErrorMessage.hidden = YES;
        //按下过搜索按钮并且搜索结果是成功的
        if (self.isUseSearchSuccess) {
            //当前的选项必须要满足点在其他项上
            self.searchText = searchBar.text;
            [self searchingYourField:selectedScope];
        }
    }
}

-(void)searchingYourField:(NSInteger)selectedScope
{
    __weak searchInfoViewController *weakSelf = self;
    NSString *attributes = @"wkName";
    NSString *tableType = @"ManongContent";
    NSString *searchKey = self.searchText;
    NSDictionary *searchInfo = @{
                                 @"searchType":tableType,
                                 @"searchKey":searchKey,
                                 @"searchAttributes":attributes
                                 };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//        if (selectedScope == 0) {
//            weakSelf.currentSelected = selectedScope;
//            NSLog(@"%@",searchInfo);
//            weakSelf.showErrorMessage.hidden = YES;
//            weakSelf.showErrorMessage.text = @"";
//            //隐藏loading
//            weakSelf.searchLoading.hidden = YES;
//            weakSelf.showSearchInfoTable.hidden = NO;
//            //解锁
//            weakSelf.isSearchBlock = NO;
//            [self.manager vagueSearchToMN:searchInfo globalSearching:^(BOOL success, NSError *error, NSArray *searchResult) {
//                
//            }];
//            
//        }else{
            NSArray *result =  [weakSelf.manager vagueSearchToMN:searchInfo];
            if (selectedScope == 1) {
                //这里实现的逻辑是，最近阅读
                weakSelf.currentSelected = selectedScope;
                NSPredicate *dicate = [NSPredicate predicateWithFormat:@"wkStatus > %@",@0];
                result = [result filteredArrayUsingPredicate:dicate];
                result = [result sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
                    ManongContent *content1 = (ManongContent *)obj1;
                    ManongContent *content2 = (ManongContent *)obj2;
                    if (![content1.wkStatus intValue]) {
                        return YES;
                    }
                    if(![content2.wkStatus intValue]){
                        return NO;
                    }
                    NSDate *date1 = content1.wkTime;
                    NSDate *date2 = content2.wkTime;
                    return date1.timeIntervalSinceNow < date2.timeIntervalSinceNow;
                }];
                //如果查询失败
                if (!result.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *errorInfo = [NSString stringWithFormat:@"匹配您对\"%@\"的搜索，没有项目在您的最近阅读列表中",searchKey];
                        //隐藏table view
                        weakSelf.showSearchInfoTable.hidden = YES;
                        weakSelf.searchLoading.hidden = YES;
                        weakSelf.showErrorMessage.hidden = NO;
                        weakSelf.showErrorMessage.text = errorInfo;
                        //解锁
                        weakSelf.isSearchBlock = NO;
                    });
                    return;
                }
                [weakSelf.searchDataSource removeAllObjects];
                [weakSelf.searchDataSource addObjectsFromArray:result];
                //在主线程中更新UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.showErrorMessage.hidden = YES;
                    weakSelf.showErrorMessage.text = @"";
                    //隐藏loading
                    weakSelf.searchLoading.hidden = YES;
                    weakSelf.showSearchInfoTable.hidden = NO;
                    //解锁
                    weakSelf.isSearchBlock = NO;
                    [weakSelf.showSearchInfoTable reloadData];
                });
            }else if(selectedScope == 0){
                weakSelf.currentSelected = selectedScope;
                if (!result.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *errorInfo = [NSString stringWithFormat:@"匹配您对\"%@\"的搜索，没有项目在您的列表中",searchKey];
                        //隐藏table view
                        weakSelf.showSearchInfoTable.hidden = YES;
                        weakSelf.searchLoading.hidden = YES;
                        weakSelf.showErrorMessage.hidden = NO;
                        weakSelf.showErrorMessage.text = errorInfo;
                        //解锁
                        weakSelf.isSearchBlock = NO;
                    });
                    return;
                }
                [weakSelf.searchDataSource removeAllObjects];
                [weakSelf.searchDataSource addObjectsFromArray:result];
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.showErrorMessage.hidden = YES;
                    weakSelf.showErrorMessage.text = @"";
                    //隐藏loading
                    weakSelf.searchLoading.hidden = YES;
                    weakSelf.showSearchInfoTable.hidden = NO;
                    //解锁
                    weakSelf.isSearchBlock = NO;
                    [weakSelf.showSearchInfoTable reloadData];
                });
            }
//        }
    });
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.exeSearchBar resignFirstResponder];
    self.showErrorMessage.text = @"";
    self.showErrorMessage.hidden = YES;
    //默认在顶部
    self.showSearchInfoTable.contentOffset = CGPointMake(0, 0);
    
    if ([self.manager isBlankString:searchBar.text]) {
        NSString *emptyErrorInfo = [NSString stringWithFormat:@"匹配您对\"%@\"的搜索，没有项目在您的列表中",searchBar.text];
        self.showSearchInfoTable.hidden = YES;
        self.showErrorMessage.text = emptyErrorInfo;
        self.showErrorMessage.hidden = NO;
        return;
    }
    //用户输入结束时，默认搜索浏览列表
    self.searchText = searchBar.text;
    if (!self.isSearchBlock) {
        /*
            搜索逻辑处理
         */
        //锁上
        self.isSearchBlock = YES;
        self.searchLoading.hidden = NO;
        //table 隐藏并且加载
        self.showSearchInfoTable.hidden = YES;
        
        //用户成功的按过一次搜索按钮
        if (!self.isUseSearchSuccess) {
            [self.exeSearchBar setScopeButtonTitles:@[@"浏览列表",@"最近阅读"]];
            self.exeSearchBar.showsScopeBar = YES;
            self.exeSearchBar.selectedScopeButtonIndex = 0;
            self.isUseSearchSuccess = YES;
        }
        //开启后台线程去查询数据
        [self searchingYourField:self.exeSearchBar.selectedScopeButtonIndex];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"searchGoToWebPage"]) {
        __weak searchInfoViewController *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            UINavigationController *navC = (UINavigationController *)segue.destinationViewController;
            webPageViewController *webPage = (webPageViewController *)navC.topViewController;
            NSIndexPath *indexPath = [weakSelf.showSearchInfoTable indexPathForSelectedRow];
            ManongContent *content = weakSelf.searchDataSource[indexPath.row];
            NSDate *date = [NSDate date];
            NSString *readTime = [weakSelf.manager createDateNowString:date];
            ManongContent *mncontent = [weakSelf.manager fetchManong:@"ManongContent" fetchKey:@"wkName" fetchValue:content.wkName];
            if (mncontent) {
                mncontent.wkTime = date;
                mncontent.wkStringTime = readTime;
                mncontent.wkStatus = @YES;
                mncontent.wkCount = [NSNumber numberWithInteger:[mncontent.wkCount integerValue] + 1];
                [weakSelf.manager saveData];
            }
            NSURL *url = [NSURL URLWithString:mncontent.wkUrl];
            webPage.requestURL = url;
            webPage.requestTitle = mncontent.wkName;
            webPage.currentMC = mncontent;
            webPage.dataSource = weakSelf.searchDataSource;
            webPage.manager = weakSelf.manager;
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backForIndex:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.exeSearchBar resignFirstResponder];
}

-(void)dealloc
{
    NSLog(@"search view controller 释放");
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
