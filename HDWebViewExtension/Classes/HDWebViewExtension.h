//
//  HDWebViewExtension.h
//  HDWebViewExtension
//
//  Created by lzh on 2018/8/20.
//

#import <Foundation/Foundation.h>
#import "HDWebViewPool.h"
#import "HDWebURLProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDWebViewExtension : NSObject

/**
 开启预加载功能
 */
+ (void)startPreloadWithWebViewClass:(Class<ZHWebViewPoolDelegate>)webClass;

/**
 开启缓存web请求功能
 */
+ (void)startCacheWebRequest;

@end

NS_ASSUME_NONNULL_END
