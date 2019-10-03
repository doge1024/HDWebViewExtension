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
#import "PostScriptMessageHandler.h"

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
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setBackgroundColor:[UIColor greenColor]];
    [btn2 setTitle:@"load" forState:UIControlStateNormal];
    btn2.frame = CGRectMake(0, 250, 50, 30);
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(btnAction2) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn setTitle:@"post" forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 300, 50, 30);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAction2 {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
}

- (void)btnAction {
    NSString *str = @"\
    fetch(\"/name\", { \
    headers: { \
    \"Content-Type\": \"application/x-www-form-urlencoded\", \
    \"HDProtocolWebPostKey\": \"1\" \
    }, \
    method: \"PUT\", \
    body: \"name=llllllll\" \
    }).then(response => response.json()).then(response => { \
    console.log(response) \
    }).catch((err)=>{ \
    console.log(err) \
    }) ";
    [self.webView evaluateJavaScript:str completionHandler:^(id _Nullable rep, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

- (ZHWebView *)webView {
    if (_webView == nil) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hook" ofType:@"js"]];
        NSString *js = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        WKUserContentController *userContent = [[WKUserContentController alloc] init];
        [userContent addScriptMessageHandler:[[PostScriptMessageHandler alloc] init] name:@"IMYXHR"];
        [userContent addUserScript:script];
        WKPreferences *preferences = [[WKPreferences alloc] init];
        preferences.javaScriptEnabled = YES;
        config.preferences = [[WKPreferences alloc] init];
        config.userContentController = userContent;
        _webView = [[ZHWebView alloc] initWithFrame:CGRectZero configuration:config];
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
