//
//  *@项目名称:  HDWebViewExtension
//  *@文件名称:  PostScriptMessageHandler.m
//  *@Date 2018/12/19
//  *@Author lzh
//

#import "PostScriptMessageHandler.h"

@implementation PostScriptMessageHandler

static NSMutableDictionary *httpDataDict = nil;
+ (NSDictionary *)getRequestHttpDataWithId:(id)requestID {
    return httpDataDict[requestID];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *httpBody = message.body[@"data"];
    id requestID = message.body[@"id"];
    if (httpBody) {
        [httpDataDict setValue:httpBody forKey:requestID];
    }
    [message.webView evaluateJavaScript:[NSString stringWithFormat:@"window.imy_realxhr_callback(%@)", requestID] completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        if (error) {
            [httpDataDict removeObjectForKey:requestID];
        }
    }];
}

@end
