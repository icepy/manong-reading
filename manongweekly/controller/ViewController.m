//
//  ViewController.m
//  manongweekly
//
//  Created by xiangwenwen on 15/4/20.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "Reachability.h"
#import "ViewController.h"
#import "tableInfoViewController.h"
#import "searchInfoViewController.h"
#import "settingViewController.h"
#import "modelManager.h"
#import "MNTagCell.h"
#import "ManongTag.h"
#import "ManongDigest.h"

BOOL isDownload = NO;

@interface ViewController ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *titleCategoryTable;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBtn;
@property (strong, nonatomic) modelManager *manager;
@property (strong, nonatomic) UIApplication *application;
@property (strong, nonatomic) NSMutableData *READMEData;
@property (strong, nonatomic) NSMutableDictionary *configData;
@property (strong, nonatomic) NSIndexPath *digestIndexPath;

//同步锁
@property (assign, nonatomic) BOOL syncBlock;
//网络监测
@property (strong, nonatomic) Reachability *reachability;
@property (assign, nonatomic) BOOL networks;
@property (weak, nonatomic) IBOutlet UILabel *showNetMessage;
@property (assign, nonatomic) BOOL isFetchData;
@property (strong, nonatomic) NSMutableArray *hideTagCon;

@end

@implementation ViewController

-(NSMutableData *)READMEData
{
    if (!_READMEData) {
        _READMEData = [[NSMutableData alloc] init];
    }
    return _READMEData;
}

-(UIApplication *)application
{
    if (!_application) {
        _application = [UIApplication sharedApplication];
    }
    return _application;
}

-(modelManager *)manager{
    if (!_manager) {
        _manager = [[modelManager alloc] init];
        _manager.dataSource = [[NSMutableArray alloc] init];
        [_manager.dataSource addObject:[[NSMutableArray alloc] init]];
        [_manager.dataSource addObject:[[NSMutableArray alloc] init]];
    }
    return _manager;
}

-(Reachability *)reachability
{
    if (!_reachability) {
        _reachability = [Reachability reachabilityWithHostName:@"www.apple.com.cn"];
    }
    return _reachability;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    __weak ViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(asyncFetchOrigin:) name:@"kFetchGithubManongData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCacheSuccess:) name:@"kRemoveCacheSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidActionInWidgetNotification:) name:@"taskDidActionInWidgetNotification" object:nil];
    
    [self.reachability startNotifier];
    self.titleCategoryTable.dataSource = self;
    self.titleCategoryTable.delegate = self;
    self.hideTagCon = [[NSMutableArray alloc] init];
    [self.manager readConfig:^(NSDictionary *config) {
        weakSelf.configData = [[NSMutableDictionary alloc] initWithDictionary:config];
        isDownload =  [config[@"download"] intValue];
        if (isDownload) {
            weakSelf.settingBtn.enabled = YES;
            weakSelf.searchBtn.enabled = YES;
            //无需下载数据源了，从core data 中获取
            [weakSelf.manager fetchAllManongTag];
        }else{
            if (!weakSelf.isFetchData) {
                weakSelf.isFetchData = YES;
                [weakSelf firstDownloadDataSource];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *appWidget = [userDefaults objectForKey:@"startApplicationWidget"];
            if (appWidget) {
                [userDefaults removeObjectForKey:@"startApplicationWidget"];
                [weakSelf taskDidActionInWidget:appWidget];
            }
        });
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.READMEData setData:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.titleCategoryTable) {
        [self.titleCategoryTable reloadData];
    }
}

-(void)applicationWillResignActive
{
    [self.manager extensionNeedDataSource];
}

-(void)taskDidActionInWidget:(NSString *)tagName
{
    tableInfoViewController *tableInfoWidget = (tableInfoViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"icepyTableInfoWidget"];
    NSMutableArray *dataTag = self.manager.dataSource[0];
    ManongTag *manongTag = (ManongTag *)[self.manager fetchManong:@"ManongTag" fetchKey:@"tagName" fetchValue:tagName];
    NSLog(@"%@",manongTag.tagKey);
    tableInfoWidget.tagToInfoParameter = manongTag.tagName;
    tableInfoWidget.manager = self.manager;
    NSLog(@"view controller Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));
    NSLog(@"model manager Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self.manager));
    if (!dataTag.count) {
        [self.manager saveDigest:nil manongDigest:manongTag isRemove:NO];
        [dataTag addObject:manongTag];
        self.digestIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }else{
        __block BOOL tag;
        [dataTag enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ManongTag *mnTag = (ManongTag *) obj;
            tag = YES;
            if ([manongTag.tagKey isEqualToString:mnTag.tagKey]) {
                tag = NO;
                *stop = YES;
            }
        }];
        if (tag) {
            //点击了不同的标签
            if (dataTag.count > 2) {
                [self.manager saveDigest:dataTag[0] manongDigest:manongTag isRemove:YES];
                [dataTag removeObjectAtIndex:0];
                [dataTag addObject:manongTag];
            }else{
                [dataTag addObject:manongTag];
                [self.manager saveDigest:nil manongDigest:manongTag isRemove:NO];
            }
        }
    }
    [self.navigationController pushViewController:tableInfoWidget animated:YES];
}

-(void)taskDidActionInWidgetNotification:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self taskDidActionInWidget:userInfo[@"appWidget"]];
}

-(void)removeCacheSuccess:(NSNotification *)note
{
    __weak ViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf showMessage:@"清除缓存成功"];
        [UIView animateWithDuration:2.2 animations:^{
            [weakSelf hiddenMessage];
        }];
    });
}

-(void)downloadDataSource:(NSDictionary *)info describeKey:(NSString *)describeKey
{
    __weak ViewController *weakSelf = self;
    NSURL *url = [NSURL URLWithString:MANDownloadPath];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFHTTPRequestOperation *connection = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    connection.responseSerializer = [AFHTTPResponseSerializer serializer];
    [connection setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [weakSelf.downloadProgress setProgress:(float)totalBytesRead/totalBytesExpectedToRead animated:YES];
    }];
    [connection setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf.READMEData appendData:(NSData *)responseObject];
        
        if ([describeKey isEqualToString:@"first"]) {
            [weakSelf showMessage:info[@"success"]];
            if(!isDownload){
                //初始化数据库
                [weakSelf.manager writeAllDataForSQLite:weakSelf.READMEData handlerCallback:^(BOOL success, NSError *error) {
                    [weakSelf hiddenMessage];
                    if (success) {
                        NSLog(@"初始化数据到数据库成功");
                        weakSelf.application.networkActivityIndicatorVisible = NO;
                        weakSelf.downloadProgress.hidden = YES;
                        weakSelf.settingBtn.enabled = YES;
                        weakSelf.searchBtn.enabled = YES;
                        [weakSelf.downloadProgress setProgress:0.0f];
                        //存储原始文件
                        NSString *filePath = [weakSelf.manager.libraryCaches stringByAppendingPathComponent:MANOriginReadmeName];
                        [weakSelf.READMEData writeToFile:filePath atomically:YES];
                        weakSelf.configData[@"download"] = @YES;
                        [weakSelf.manager writeConfig:self.configData];
                        //驱动table view 渲染
                        [weakSelf.titleCategoryTable reloadData];
                    }else{
                        [weakSelf showMessage:@"初始化数据库失败了"];
                    }
                }];
            }
        }else{
            [weakSelf showMessage:info[@"success"]];
            [weakSelf.manager updateDataSourceForSQLite:weakSelf.READMEData handlerCallback:^(BOOL success, NSError *error) {
                [weakSelf hiddenMessage];
                NSString *filePath = [weakSelf.manager.libraryCaches stringByAppendingPathComponent:MANOriginReadmeName];
                [weakSelf.READMEData writeToFile:filePath atomically:YES];
                //关闭网络visible
                weakSelf.application.networkActivityIndicatorVisible = NO;
                weakSelf.downloadProgress.hidden = YES;
                [weakSelf.downloadProgress setProgress:0.0f];
                //解锁
                weakSelf.syncBlock = NO;
                [weakSelf.titleCategoryTable reloadData];
            }];

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //进度动画停止
        weakSelf.downloadProgress.hidden = YES;
        weakSelf.application.networkActivityIndicatorVisible = NO;
        [weakSelf.downloadProgress setProgress:0.0f];
        [weakSelf showMessage:info[@"error"]];
        [UIView animateWithDuration:2.4 animations:^{
            [weakSelf hiddenMessage];
        }];
        if ([describeKey isEqualToString:@"update"]) {
            //解锁
            weakSelf.syncBlock = NO;
        }
    }];
    [connection start];
}

-(void)updateDataSource
{
    //task 2 更新远程github上的分类数据
    [self.downloadProgress setProgress:0.0f];
    self.downloadProgress.hidden = NO;
    self.application.networkActivityIndicatorVisible = YES;
    [self downloadDataSource:@{@"error":@"未知网络错误，更新语言分类失败",@"success":@"更新数据源成功^_^...稍等正在更新本地数据库"} describeKey:@"update"];
}

-(void)firstDownloadDataSource
{
    //task 1下载远程github上的分类数据
    self.application.networkActivityIndicatorVisible = YES;
    self.downloadProgress.hidden = NO;
    [self.downloadProgress setProgress:0.0 animated:YES];
    [self downloadDataSource:@{@"error":@"下载数据源失败",@"success":@"下载数据源成功^_^...稍等正在写入本地数据库"} describeKey:@"first"];
}

-(void)reachabilityChanged:(NSNotification *)note
{
    Reachability *reach = (Reachability *)[note object];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status) {
        [self hiddenMessage];
        self.networks = YES;
        if (!isDownload && !self.isFetchData) {
            self.isFetchData = YES;
            [self firstDownloadDataSource];
        }
    }else{
        self.networks = NO;
        [self showMessage:nil];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.manager.dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *arr = self.manager.dataSource[section];
    return arr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNTagCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MNTagCell" forIndexPath:indexPath];
    NSMutableArray *dataArray = self.manager.dataSource[indexPath.section];
    if (dataArray.count > 0) {
        cell.manongTag = dataArray[indexPath.row];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak ViewController *weakSelf = self;
    return [tableView fd_heightForCellWithIdentifier:@"MNTagCell" configuration:^(MNTagCell *cell) {
        NSMutableArray *dataArray = weakSelf.manager.dataSource[indexPath.section];
        if (dataArray.count > 0) {
            cell.manongTag = dataArray[indexPath.row];
        }
    }];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? @"浏览标签" : @"语言分类";
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"view controller Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));
    NSLog(@"model manager Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self.manager));
    if ([segue.identifier isEqualToString:@"SettingModal"]) {
        __weak ViewController *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            UINavigationController *navC = (UINavigationController *)segue.destinationViewController;
            settingViewController *setting = (settingViewController *)navC.topViewController;
            setting.manager = weakSelf.manager;
        });
    }
    
    if ([segue.identifier isEqualToString:@"gotoSearch"]) {
        searchInfoViewController *searchMN = (searchInfoViewController *) segue.destinationViewController;
        searchMN.manager = self.manager;
    }
    
    if ([segue.identifier isEqualToString:@"gotoContent"]) {
        NSIndexPath *indexPath = [self.titleCategoryTable indexPathForSelectedRow];
        NSMutableArray *dataArray = self.manager.dataSource[indexPath.section];
        NSMutableArray *dataTag = self.manager.dataSource[0];
        if (dataArray.count) {
            tableInfoViewController *tableInfo = (tableInfoViewController *)segue.destinationViewController;
            ManongTag *manongTag = dataArray[indexPath.row];
            tableInfo.tagToInfoParameter = manongTag.tagName;
            tableInfo.manager = self.manager;
            if (!dataTag.count) {
                [self.manager saveDigest:nil manongDigest:manongTag isRemove:NO];
                [dataTag addObject:manongTag];
                self.digestIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            }else{
                __block BOOL tag;
                [dataTag enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    ManongTag *mnTag = (ManongTag *) obj;
                     tag = YES;
                    if ([manongTag.tagKey isEqualToString:mnTag.tagKey]) {
                        tag = NO;
                        *stop = YES;
                    }
                }];
                if (tag) {
                    //点击了不同的标签
                    if (dataTag.count > 2) {
                        [self.manager saveDigest:dataTag[0] manongDigest:manongTag isRemove:YES];
                        [dataTag removeObjectAtIndex:0];
                        [dataTag addObject:manongTag];
                    }else{
                        [dataTag addObject:manongTag];
                        [self.manager saveDigest:nil manongDigest:manongTag isRemove:NO];
                    }
                }
            }
        }
    }
}

-(void)asyncFetchOrigin:(NSNotification *)note
{
    [self asyncForOriginData];
}

- (void)asyncForOriginData{
    NSLog(@"同步数据");
    if (self.networks) {
        if (!self.syncBlock) {
            //锁上，一直到检索完成
            self.syncBlock = YES;
            [self updateDataSource];
        }
    }else{
        [self showMessage:nil];
    }
}

-(void)showMessage:(NSString *)message
{
    NSString *showMessage = @"世界上最遥远的距离就是没网--请检查设置";
    if (message) {
        showMessage = message;
    }
    __weak ViewController *weakSelf = self;
    self.showNetMessage.text = showMessage;
    self.showNetMessage.hidden = NO;
    self.showNetMessage.alpha = 0.0f;
    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.showNetMessage.alpha = 1.0f;
    }];
}

-(void)hiddenMessage
{
    __weak ViewController *weakSelf = self;
    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.showNetMessage.alpha = 0.0f;
    } completion:^(BOOL finished) {
        weakSelf.showNetMessage.hidden = YES;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"viewController 销毁");
}

@end