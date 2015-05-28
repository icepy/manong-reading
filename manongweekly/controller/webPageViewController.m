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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backViewButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardViewButton;
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
    
    __weak webPageViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.swipeGestureRigth.delegate = weakSelf;
        weakSelf.actionNumber = 0;
        weakSelf.showNotNetMessage.numberOfLines = 0;
        
        if ([weakSelf.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            weakSelf.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
        }
        
        [weakSelf.view insertSubview:weakSelf.WKWebPageView belowSubview:weakSelf.WKWebLoading];
        NSURLRequest *request = [NSURLRequest requestWithURL:weakSelf.requestURL];
        [weakSelf.WKWebPageView loadRequest:request];
        weakSelf.showNotNetMessage.hidden = YES;
        [weakSelf.WKWebPageView addObserver:weakSelf forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [weakSelf.WKWebPageView addObserver:weakSelf forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        [weakSelf.WKWebPageView addObserver:weakSelf forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
        [weakSelf.WKWebPageView addObserver:weakSelf forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
        [weakSelf.WKWebPageView addObserver:weakSelf forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
        weakSelf.WKWebPageView.allowsBackForwardNavigationGestures = YES;
        NSLog(@"%@",self.requestURL);
    });
    
    
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
        if (self.WKWebPageView.URL) {
            self.requestURL = self.WKWebPageView.URL;
        }
        
    }
    
    if ([keyPath isEqualToString:@"canGoBack"]) {
        self.backViewButton.enabled = YES;
        if (!self.WKWebPageView.backForwardList.backList.count) {
            self.backViewButton.enabled = NO;
            self.forwardViewButton.enabled = YES;
        }
    }
    
    if ([keyPath isEqualToString:@"canGoForward"]) {
        self.forwardViewButton.enabled = NO;
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

- (IBAction)closeModalView:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openSafari:(UIBarButtonItem *)sender {
    [self.application openURL:self.requestURL];
}

- (IBAction)reloadCurrentURL:(UIBarButtonItem *)sender {
    self.application.networkActivityIndicatorVisible = YES;
    self.WKWebLoading.hidden = NO;
    [self.WKWebPageView reloadFromOrigin];
}

- (IBAction)forwardURL:(UIBarButtonItem *)sender {
    [self.WKWebPageView goForward];
}

- (IBAction)backURL:(UIBarButtonItem *)sender {
    [self.WKWebPageView goBack];
}

-(void)dealloc
{
    self.application.networkActivityIndicatorVisible = NO;
    [self.WKWebPageView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.WKWebPageView removeObserver:self forKeyPath:@"title"];
    [self.WKWebPageView removeObserver:self forKeyPath:@"URL"];
    [self.WKWebPageView removeObserver:self forKeyPath:@"canGoBack"];
    [self.WKWebPageView removeObserver:self forKeyPath:@"canGoForward"];
//    NSLog(@"%@",NSStringFromCGSize(self.WKWebPageView.scrollView.contentSize));
    NSLog(@"web page view controller 销毁");
}

@end
