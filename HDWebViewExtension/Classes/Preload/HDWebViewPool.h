//
//  HDWebViewPool.h
//  HDWebViewExtension
//
//  Created by lzh on 2018/8/20.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HDWebViewPoolDelegate <NSObject>
@required
+ (instancetype)createPreLoadWebView;
@end

@interface HDWebViewPool : NSObject

/**
 max create webview, default is 1
 */
@property (nonatomic, assign) NSInteger maxReusedWebViewCount;

/**
 自己需要预初始化的webView，需要遵循协议
 */
@property (nonatomic, strong) Class<HDWebViewPoolDelegate> webViewClass;

+ (instancetype)shareInstance;

/**
 开始预加载webView, 你需要在这之前设置 webViewClass
 */
+ (void)startPreload;

/**
 获取一个预加载的webView
 */
- (__kindof WKWebView *)getReusedWebView;

@end

NS_ASSUME_NONNULL_END
