//
//  HDWebViewExtension.m
//  HDWebViewExtension
//
//  Created by lzh on 2018/8/20.
//

#import "HDWebViewExtension.h"

@implementation HDWebViewExtension

/**
 开启预加载功能
 */
+ (void)startPreloadWithWebViewClass:(Class<ZHWebViewPoolDelegate>)webClass {
    [HDWebViewPool shareInstance].webViewClass = webClass;
    [HDWebViewPool shareInstance].maxReusedWebViewCount = 1;
    [HDWebViewPool startPreload];
}

/**
 开启缓存web请求功能
 */
+ (void)startCacheWebRequest {
    // 默认缓存js
    HDURLProtocolCheckUrl canInitBlock = ^(NSURLRequest *request) {
        NSPredicate *predicatejs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^http.*.js"];
        NSString *url = request.URL.absoluteString;
        if ([predicatejs evaluateWithObject:url]) {
            return YES;
        }
        return NO;
    };
    [self setRequestFilter:[NSSet setWithObjects:canInitBlock, nil]];
    
    [HDWebURLProtocol registerClass];
}

@end
