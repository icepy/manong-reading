//
//  webPageViewController.m
//  manongweekly
//
//  Created by xiangwenwen on 15/4/20.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "WXApi.h"
#import "Reachability.h"
#import "WeixinSessionActivity.h"
#import "WeixinTimelineActivity.h"
#import "webPageViewController.h"


@interface webPageViewController()<WKNavigationDelegate,UIGestureRecognizerDelegate>

@property (strong,nonatomic) UIApplication *application;
@property (strong,nonatomic) UIActivityViewController *activc;
@property (strong,nonatomic) WKWebView *WKWebPageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *WKWebLoading;
@property (weak, nonatomic) IBOutlet UILabel *showNotNetMessage;
@property (weak, nonatomic) IBOutlet UIProgressView *WKWebProgress;

@property (strong,nonatomic) UIButton *closeCurrentView;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGestureRigth;

@property (assign,nonatomic) NSInteger actionNumber;

@end

@implementation webPageViewController

-(UIApplication *)application
{
    if (!_application) {
        _application = [UIApplication sharedApplication];
    }
    return _application;
}

-(WKWebView *)WKWebPageView
{
    if (!_WKWebPageView) {
        
        _WKWebPageView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _WKWebPageView.navigationDelegate = self;
    }
    return _WKWebPageView;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.swipeGestureRigth.delegate = self;
    self.actionNumber = 0;
    self.showNotNetMessage.numberOfLines = 0;
    
    self.closeCurrentView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeCurrentView.frame = CGRectMake(0, 0, 40, 44);
    self.closeCurrentView.hidden = YES;
    [self.closeCurrentView setTitle:@"关闭" forState:UIControlStateNormal];
    [self.closeCurrentView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.closeCurrentView addTarget:self action:@selector(closeCurrentView:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *backView = [UIButton buttonWithType:UIButtonTypeCustom];
    backView.frame = CGRectMake(0, 0, 70, 28);
    [backView setTitle:@"返回" forState:UIControlStateNormal];
    [backView setImage:[UIImage imageNamed:@"BackIcon"] forState:UIControlStateNormal];
    [backView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backView addTarget:self action:@selector(backPage:) forControlEvents:UIControlEventTouchUpInside];
    backView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    backView.titleLabel.font = [UIFont systemFontOfSize:16];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:self.closeCurrentView];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    
    self.navigationItem.leftBarButtonItems = @[backItem,closeItem];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    [self.view insertSubview:self.WKWebPageView belowSubview:self.WKWebLoading];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.requestURL];
    [self.WKWebPageView loadRequest:request];
    self.showNotNetMessage.hidden = YES;
    [self.WKWebPageView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.WKWebPageView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.WKWebPageView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    [self.WKWebPageView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    self.WKWebPageView.allowsBackForwardNavigationGestures = YES;
}

-(void)backPage:(UIButton *)sender
{
    WKBackForwardList *list = self.WKWebPageView.backForwardList;
    NSArray *backList = list.backList;
    if (!backList.count) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.WKWebPageView goBack];
    }
    
}

-(void)closeCurrentView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)swipeBackOrClose:(UISwipeGestureRecognizer *)sender {
    WKBackForwardList *list = self.WKWebPageView.backForwardList;
    NSArray *backList = list.backList;
    if (!backList.count) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.WKWebPageView goBack];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (self.WKWebPageView.estimatedProgress == 1) {
            self.WKWebProgress.hidden = YES;
        }
        [self.WKWebProgress setProgress:self.WKWebPageView.estimatedProgress animated:YES];
    }
    if ([keyPath isEqualToString:@"title"]) {
        self.navigationItem.title = self.WKWebPageView.title;
        self.requestTitle = self.WKWebPageView.title;
    }
    
    if ([keyPath isEqualToString:@"URL"]) {
        self.requestURL = self.WKWebPageView.URL;
    }
    
    if ([keyPath isEqualToString:@"canGoBack"]) {
        NSLog(@"can go back %zd",self.WKWebPageView.canGoBack);
        self.closeCurrentView.hidden = !self.WKWebPageView.canGoBack;
    }
}

//页面开始加载时
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    self.application.networkActivityIndicatorVisible = YES;
    self.WKWebLoading.hidden = NO;
    self.WKWebProgress.hidden = NO;
    [self.WKWebProgress setProgress:0.0f];
    self.requestURL = webView.URL;
    self.actionNumber += 1;
}


//页面加载完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.application.networkActivityIndicatorVisible = NO;
    self.WKWebLoading.hidden = YES;
    [self.WKWebProgress setProgress:0.0f animated:NO];
    
    NSLog(@"%@",NSStringFromCGSize(self.WKWebPageView.scrollView.contentSize));
    CGSize scrollContentSize = self.WKWebPageView.scrollView.contentSize;
    scrollContentSize.width = self.WKWebPageView.frame.size.width;
    self.WKWebPageView.scrollView.contentSize = scrollContentSize;
    NSLog(@"contentsize%@",NSStringFromCGSize(self.WKWebPageView.scrollView.contentSize));
    NSLog(@"%@",NSStringFromCGRect(self.WKWebPageView.frame));
    
//    self.WKWebPageView.scrollView.contentOffset = CGPointMake(0, 64);
//    NSString *js = @"var WKWDoc = document.getElementsByTagName('body')[0];WKWDoc.style.overflowX='hidden';WKWDoc.style.color='red';";
//    NSLog(@"%@",js);
//    [self.WKWebPageView evaluateJavaScript:js completionHandler:^(id k, NSError *e) {
//        NSLog(@"%@",e);
//    }];
}

//页面加载失败
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSDictionary *userInfo = error.userInfo;
    self.application.networkActivityIndicatorVisible = NO;
    self.WKWebLoading.hidden = YES;
    self.showNotNetMessage.hidden = NO;
    self.showNotNetMessage.text =  [NSString stringWithFormat:@"访问到%@的连接尝试遭到拒绝。原因可能是该网站已崩溃，也可能是您的网络配置不正确。",userInfo[@"NSErrorFailingURLStringKey"]];
    
    self.WKWebPageView.hidden = YES;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)actionShare:(UIBarButtonItem *)sender {
    BOOL isweixin = [WXApi isWXAppInstalled];
    NSString *shareText = [NSString stringWithFormat:@"%@ Origin:%@",self.requestTitle,self.requestURL.host];
    NSArray *activityItems = @[shareText,[UIImage imageNamed:@"shareIcon"],self.requestURL];
    NSArray *activity = nil;
    if (isweixin) {
        activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];
    }
    self.activc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activity];
    self.activc.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint];
    [self presentViewController:self.activc animated:YES completion:nil];
}

-(void)dealloc
{
    self.application.networkActivityIndicatorVisible = NO;
    [self.WKWebPageView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.WKWebPageView removeObserver:self forKeyPath:@"title"];
    [self.WKWebPageView removeObserver:self forKeyPath:@"URL"];
    [self.WKWebPageView removeObserver:self forKeyPath:@"canGoBack"];
//    NSLog(@"%@",NSStringFromCGSize(self.WKWebPageView.scrollView.contentSize));
    NSLog(@"web page view controller 销毁");
}

@end
