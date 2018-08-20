//
//  ZHWebView.h
//  ZHWebView_Example
//
//  Created by lzh on 2018/8/16.
//  Copyright © 2018年 harddog. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <HDWebViewExtension/HDWebViewExtension.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHWebView : WKWebView <HDWebViewPoolDelegate>

+ (instancetype)createPreLoadWebView;

@end

NS_ASSUME_NONNULL_END
