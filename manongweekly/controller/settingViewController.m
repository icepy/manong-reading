//
//  settingViewController.m
//  manongweekly
//
//  Created by xiangwenwen on 15/5/8.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//


//#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import <AFNetworking/AFNetworking.h>
#import "settingViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "HTMLStringParse.h"
#import "MNSettingCell.h"
#import "referralPageViewController.h"
#import "readingChartViewController.h"
#import "privacyPolicyViewController.h"



@interface settingViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingTable;
@property (strong, nonatomic) NSArray *dataSource;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *showLoading;
@property (weak, nonatomic) IBOutlet UIView *showShade;
@property (strong, nonatomic) NSDictionary *identifierMap;
@property (strong, nonatomic) UISwitch *dknightSwitchView;
@property (strong, nonatomic) UIApplication *application;

@end

@implementation settingViewController

-(UIApplication *)application
{
    if (!_application) {
        _application = [UIApplication sharedApplication];
    }
    return _application;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //mailto:xiangwenwe@foxmail.com?SUBJECT=About 猿已阅
    //https://itunes.apple.com/cn/app/yuan-yi-yue/id990227579?l=en&mt=8
    
    /*
     @{
     @"setName":@"订阅《码农周刊》快捷通道",
     @"setIcon":@"ManongRessImage"
     }
     
     */
    self.dataSource = @[
                        @[
                            @{
                                @"setName":@"图表天梯",
                                @"setIcon":@"RankFillImage"
                                },
                            @{
                                @"setName":@"应用介绍",
                                @"setIcon":@"ProtocolReadImage"
                                },
                            @{
                                @"setName":@"隐私政策与订阅",
                                @"setIcon":@"PrivacyImage"
                                }
                            ],
                        @[
                            @{
                                @"setName":@"意见反馈",
                                @"setIcon":@"ToMessageMeImage"
                                },
                            @{
                                @"setName":@"给个好评",
                                @"setIcon":@"ToLikeMeImage"
                                },
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
                           @"图表天梯":@"readingChart",
                           @"应用介绍":@"referralPage",
                           @"隐私政策与订阅":@"privacyPolicyPage"
                           };
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backIndexView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)fetchCRSFID:(void(^)(NSString *CRSFID,NSError *error))callback
{
//    __weak settingViewController *weakSelf = self;
    NSString *URLCsrf = @"http://weekly.manong.io/";
    NSURL *url = [NSURL URLWithString:URLCsrf];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *Operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    Operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.application.networkActivityIndicatorVisible = YES;
    [Operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = (NSData *)responseObject;
        HTMLStringParse *parse = [[HTMLStringParse alloc] initWithContentParse:data];
        NSString *_CRSF = [parse manongCRSFID];
        callback(_CRSF,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(nil,error);
    }];
    [Operation start];
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
    cell.section = indexPath.section;
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
//    __weak settingViewController *weakSelf = self;
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
            
//            if ([tag isEqualToString:@"订阅《码农周刊》快捷通道"]) {
//                SCLAlertView *alert = [[SCLAlertView alloc] init];
//                [alert setTitleFontFamily:@"Superclarendon" withSize:20.0f];
//                [alert setBodyTextFontFamily:@"TrebuchetMS" withSize:14.0f];
//                [alert setButtonsTextFontFamily:@"Baskerville" withSize:14.0f];
//                UITextField *textField = [alert addTextField:@"Enter your email"];
//                textField.delegate = self;
//                __block NSString *enterEmail;
//                [alert addButton:@"确定" validationBlock:^BOOL{
//                    enterEmail = textField.text;
//                    if (enterEmail.length > 0) {
//                        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
//                        NSPredicate *dicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
//                        if ([dicate evaluateWithObject:enterEmail]) {
//                            [weakSelf fetchCRSFID:^(NSString *CRSFID, NSError *error) {
//                                weakSelf.application.networkActivityIndicatorVisible = NO;
//                                if (CRSFID != nil) {
//                                    NSString *URLApi = @"http://weekly.manong.io/subscribe";
//                                    NSURL *URL = [NSURL URLWithString:URLApi];
//                                    NSMutableURLRequest *requestURL = [NSMutableURLRequest requestWithURL:URL];
//                                    requestURL.HTTPMethod = @"POST";
//                                    [requestURL addValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//                                    //_csrf=84e3cf9953256cce1fe3891400c599860c0f21c2&email=123%40qq.com
//
//                                    NSData *JSONBody = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"_csrf=%@&email=%@",CRSFID,enterEmail]];
//                                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//                                    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//                                    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//                                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//                                    [manager POST:URLApi parameters:JSONBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingAllowFragments error:nil];
//                                        NSLog(@"response --- %@",responseJSON);
//                                        NSLog(@"%@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
//                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                        NSDictionary *userInfo = error.userInfo;
//                                        NSString *errorInfo = [NSString stringWithFormat:@"Error API %@ ",userInfo[@"NSErrorFailingURLStringKey"]];
//                                        dispatch_async(dispatch_get_main_queue(), ^{
//                                            SCLAlertView *errorAlert = [[SCLAlertView alloc] init];
//                                            [errorAlert showError:weakSelf title:@"Error"
//                                                         subTitle:errorInfo
//                                                 closeButtonTitle:@"确定" duration:3.0f];
//                                        });
//                                    }];
//                                }
//                            }];
//                            return NO;
//                            NSString *URLApi = @"http://weekly.manong.io/subscribe";
//                            NSURL *URL = [NSURL URLWithString:URLApi];
//                            NSMutableURLRequest *requestURL = [NSMutableURLRequest requestWithURL:URL];
//                            NSURLSessionConfiguration *configur = [NSURLSessionConfiguration defaultSessionConfiguration];
//                            NSURLSession *session = [NSURLSession sessionWithConfiguration:configur];
//                            NSURLSessionDataTask *task = [session dataTaskWithRequest:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                if (error){
//                                    NSDictionary *userInfo = error.userInfo;
//                                    NSString *errorInfo = [NSString stringWithFormat:@"Error API %@ ",userInfo[@"NSErrorFailingURLStringKey"]];
//                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        SCLAlertView *errorAlert = [[SCLAlertView alloc] init];
//                                        [errorAlert showError:weakSelf title:@"Error"
//                                                     subTitle:errorInfo
//                                             closeButtonTitle:@"确定" duration:3.0f];
//                                    });
//                                }else{
//                                    NSError *JSONError = nil;
//                                    NSDictionary *JSONParse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
//                                    if (JSONError) {
//                                        NSDictionary *JSONUserInfo = JSONError.userInfo;
//                                        NSString *JSONErrorInfo = [NSString stringWithFormat:@"Error %@",JSONUserInfo[@"NSErrorFailingURLStringKey"]];
//                                        dispatch_async(dispatch_get_main_queue(), ^{
//                                            SCLAlertView *errorAlert = [[SCLAlertView alloc] init];
//                                            [errorAlert showError:weakSelf title:@"Error"
//                                                         subTitle:JSONErrorInfo
//                                                 closeButtonTitle:@"确定" duration:3.0f];
//                                        });
//                                    }else{
//                                        if(JSONParse[@"error"]) {
//                                            dispatch_async(dispatch_get_main_queue(), ^{
//                                                SCLAlertView *notEmailAlert = [[SCLAlertView alloc] initWithNewWindow];
//                                                [notEmailAlert showError:@"Error" subTitle:@"输入的Email已存在" closeButtonTitle:@"确定" duration:3.0f];
//                                            });
//                                        }else{
//                                           dispatch_async(dispatch_get_main_queue(), ^{
//                                               SCLAlertView *successAlert = [[SCLAlertView alloc] initWithNewWindow];
//                                               [successAlert showSuccess:@"Success" subTitle:@"订阅《码农周刊》成功"closeButtonTitle:@"确定" duration:2.0f];
//                                           });
//                                        }
//                                    }
//                                }
//                            }];
//                            [task resume];
//                            return YES;
//                        }else{
//                            textField.leftViewMode = UITextFieldViewModeAlways;
//                            textField.layer.borderColor = [UIColor colorWithRed:1.000 green:0.400 blue:0.400 alpha:1.000].CGColor;
//                            return NO;
//                        }
//                    }else{
//                        textField.leftViewMode = UITextFieldViewModeAlways;
//                        textField.layer.borderColor = [UIColor colorWithRed:1.000 green:0.400 blue:0.400 alpha:1.000].CGColor;
//                        return NO;
//                    }
//                } actionBlock:^{
//                    NSLog(@"%@",enterEmail);
//                }];
//                alert.completeButtonFormatBlock = ^NSDictionary* (void)
//                {
//                    NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
//                    buttonConfig[@"backgroundColor"] = [UIColor colorWithRed:0.000 green:0.502 blue:0.502 alpha:1.000];
//                    buttonConfig[@"borderColor"] = [UIColor colorWithRed:0.000 green:0.502 blue:0.502 alpha:1.000];
//                    buttonConfig[@"borderWidth"] = @"1.0f";
//                    buttonConfig[@"textColor"] = [UIColor whiteColor];
//                    return buttonConfig;
//                };
//                
//                alert.attributedFormatBlock = ^NSAttributedString* (NSString *value)
//                {
//                    NSMutableAttributedString *subTitle = [[NSMutableAttributedString alloc]initWithString:value];
//                    NSRange redRange = [value rangeOfString:@"Attributed" options:NSCaseInsensitiveSearch];
//                    [subTitle addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:redRange];
//                    NSRange greenRange = [value rangeOfString:@"successfully" options:NSCaseInsensitiveSearch];
//                    [subTitle addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor] range:greenRange];
//                    NSRange underline = [value rangeOfString:@"completed" options:NSCaseInsensitiveSearch];
//                    [subTitle addAttributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)} range:underline];
//                    return subTitle;
//                };
//                NSString *kAttributeTitle = @"输入你的email，订阅《码农周刊》享受一周编程技术精选";
//                [alert showTitle:self title:@"免费订阅" subTitle:kAttributeTitle style:Success closeButtonTitle:@"取消" duration:0.0f];
//            }
            
            if ([tag isEqualToString:@"意见反馈"]) {
                NSMutableString *mailUrl = [[NSMutableString alloc]init];
                //添加收件人
                NSArray *toRecipients = [NSArray arrayWithObject: @"xiangwenwe@foxmail.com"];
                [mailUrl appendFormat:@"mailto:%@", [toRecipients componentsJoinedByString:@","]];
                //添加主题
                [mailUrl appendString:@"?subject=About 猿已阅"];
                NSString *email = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                [self.application openURL:[NSURL URLWithString:email]];
            }
            
            if ([tag isEqualToString:@"给个好评"]) {
                NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/yuan-yi-yue/id990227579?l=en&mt=8"];
                [self.application openURL:url];
            }
        }
    }else{
        NSString *identifier = self.identifierMap[tag];
        if ([identifier isEqualToString:@"referralPage"]){
            referralPageViewController *referral = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            referral.referraTitle = tag;
            [self.navigationController pushViewController:referral animated:YES];
        }else if ([identifier isEqualToString:@"readingChart"]){
            readingChartViewController *readChart = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            readChart.readingChartTitle = tag;
            readChart.manager = self.manager;
            [self.navigationController pushViewController:readChart animated:YES];
        }else if ([identifier isEqualToString:@"privacyPolicyPage"]){
            privacyPolicyViewController *policy = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            policy.policyTitle = tag;
            [self.navigationController pushViewController:policy animated:YES];
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
