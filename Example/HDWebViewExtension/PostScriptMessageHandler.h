//
//  *@项目名称:  HDWebViewExtension
//  *@文件名称:  PostScriptMessageHandler.h
//  *@Date 2018/12/19
//  *@Author lzh 
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PostScriptMessageHandler : NSObject <WKScriptMessageHandler>

+ (NSDictionary *)getRequestHttpDataWithId:(id)requestID;

@end

NS_ASSUME_NONNULL_END
