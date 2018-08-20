//
//  HDWebURLProtocol.h
//  HDWebViewExtension
//
//  Created by lzh on 2018/8/20.
//

#import <Foundation/Foundation.h>

/// HttpHeaderKey， 是否拦截请求的关键字
extern NSString *const HDProtocolHttpHeaderKey;

typedef BOOL(^HDURLProtocolCheckUrl)(NSURLRequest *request);

NS_ASSUME_NONNULL_BEGIN

@interface HDWebURLProtocol : NSURLProtocol

/**
 需要过滤的url的 正则规则的集合
 */
@property(nonatomic, copy, class, nullable) NSSet *requestFilter;

/**
 缓存时间, 默认 (60 * 60 * 3)
 */
@property(nonatomic, assign, class) NSUInteger cacheTime;

/**
 需要在较早时机调用此方法，开启对url的拦截
 */
+ (void)registerClass;

@end

NS_ASSUME_NONNULL_END
