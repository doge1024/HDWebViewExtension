//
//  ZHWebViewController.m
//  ZHWebView_Example
//
//  Created by lzh on 2018/8/16.
//  Copyright © 2018年 harddog. All rights reserved.
//

#import "ZHWebViewController.h"
#import "ZHWebView.h"
#import <HDWebViewExtension/HDWebViewExtension.h>

@interface ZHWebViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) ZHWebView *webView;

@property (nonatomic, strong) NSDate *firstDate;

@end

@implementation ZHWebViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.firstDate = [NSDate date];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.frame = self.view.bounds;
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:45];
    [self.webView loadRequest:request];
}


- (ZHWebView *)webView {
    if (_webView == nil) {
        if ([HDWebViewPool shareInstance].webViewClass) {
            _webView = [[HDWebViewPool shareInstance] getReusedWebView];
        } else {
            _webView = [[ZHWebView alloc] init];
        }
        _webView.navigationDelegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"time is %f", [[NSDate date] timeIntervalSinceDate:self.firstDate]);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
