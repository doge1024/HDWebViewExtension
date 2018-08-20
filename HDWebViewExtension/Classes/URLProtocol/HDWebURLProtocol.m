//
//  HDWebURLProtocol.m
//  HDWebViewExtension
//
//  Created by lzh on 2018/8/20.
//

#import "HDWebURLProtocol.h"
#import "NSURLProtocol+HDWebKitSupport.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

#if 1
#define NSLog(...) {}
#endif

/// HttpHeaderKey， 是否拦截请求的关键字
NSString *const HDProtocolHttpHeaderKey = @"HDProtocolHttpHeaderKey";

@interface NSURLRequest(mutableCopySubstitute)
- (NSMutableURLRequest *)mutableCopySubstitute;
@end

@interface NSString (MD5)
- (NSString *)md5String;
@end

@interface HDWebURLProtocolCacheData : NSObject<NSCoding>
@property (nonatomic, strong) NSDate *addDate;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSURLRequest *redirectRequest;
@end


@interface HDWebURLProtocol ()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *cacheData;
@end

@implementation NSURLRequest (mutableCopySubstitute)

- (NSMutableURLRequest *)mutableCopySubstitute {
    
    NSMutableURLRequest *mutableCopy = [[NSMutableURLRequest alloc] initWithURL:[self URL]
                                                                    cachePolicy:[self cachePolicy]
                                                                timeoutInterval:[self timeoutInterval]];
    
    [mutableCopy setAllHTTPHeaderFields:[self allHTTPHeaderFields]];
    [mutableCopy setHTTPMethod:[self HTTPMethod]];
    
    if ([self HTTPBodyStream]) {
        [mutableCopy setHTTPBodyStream:[self HTTPBodyStream]];
    } else {
        [mutableCopy setHTTPBody:[self HTTPBody]];
    }
    
    return mutableCopy;
}

@end

@implementation NSString(MD5)

- (NSString *)md5String {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end

@implementation HDWebURLProtocolCacheData
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    unsigned int count;
    Ivar *ivar = class_copyIvarList([self class], &count);
    for (int i = 0 ; i < count ; i++) {
        Ivar iv = ivar[i];
        const char *name = ivar_getName(iv);
        NSString *strName = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:strName];
        [aCoder encodeObject:value forKey:strName];
    }
    free(ivar);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        unsigned int count = 0;
        Ivar *ivar = class_copyIvarList([self class], &count);
        for (int i= 0 ;i < count ; i++) {
            Ivar var = ivar[i];
            const char *keyName = ivar_getName(var);
            NSString *key = [NSString stringWithUTF8String:keyName];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivar);
    }
    return self;
}

@end

@implementation HDWebURLProtocol

+ (void)registerClass {
    [NSURLProtocol registerClass:[HDWebURLProtocol class]];
    [HDWebURLProtocol wk_registerScheme:@"http"];
    [HDWebURLProtocol wk_registerScheme:@"https"];
    
    if (![self requestFilter]) {
        // 默认缓存js css
        HDURLProtocolCheckUrl canInitBlock = ^(NSURLRequest *request) {
            NSPredicate *predicatejs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^http.*.js"];
            NSPredicate *predicatecss = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^http.*.css"];
            NSString *url = request.URL.absoluteString;
            if ([predicatejs evaluateWithObject:url] || [predicatecss evaluateWithObject:url]) {
                return YES;
            }
            return NO;
        };
        [self setRequestFilter:[NSSet setWithObjects:canInitBlock, nil]];
    }
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return _session;
}

#pragma mark - get & set
static NSSet *HDURLSessionFilterUrlCheck;
+ (NSSet *)requestFilter {
    NSSet *set;
    @synchronized(self) {
        set = HDURLSessionFilterUrlCheck;
    }
    return set;
}

+ (void)setRequestFilter:(NSSet *)requestFilter {
    @synchronized(self) {
        HDURLSessionFilterUrlCheck = requestFilter;
    }
}

/// 缓存的时间
static NSUInteger HDRequestCacheTime = (60 * 60 * 3);
+ (NSUInteger)cacheTime {
    return HDRequestCacheTime;
}

+ (void)setCacheTime:(NSUInteger)cacheTime {
    HDRequestCacheTime = cacheTime;
}

#pragma mark - privateFunc

- (NSString *)p_filePathWithUrlString:(NSString *)urlString {
    
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [urlString md5String];
    return [cachesPath stringByAppendingPathComponent:fileName];
}

- (BOOL)p_isUseCahceWithCacheData:(HDWebURLProtocolCacheData *)cacheData {
    
    if (cacheData == nil) {
        return NO;
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:cacheData.addDate];
    return timeInterval < [[self class] cacheTime];
}

+ (BOOL)p_isFilterWithUrlRequest:(NSURLRequest *)request {
    
    BOOL state = NO;
    for (HDURLProtocolCheckUrl canInit in [self requestFilter]) {
        // 对字符串进行判断
        BOOL canInitWithRequest = canInit(request);
        if (canInitWithRequest) {
            state = YES;
            break;
        }
    }
    return state;
}

#pragma mark - override
+ (BOOL)canInitWithTask:(NSURLSessionTask *)task {
    NSURLRequest *request = task.currentRequest;
    return [self canInitWithRequest:request];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    if ([request valueForHTTPHeaderField:HDProtocolHttpHeaderKey]) {
        // 不拦截请求头中包含HDProtocolHttpHeaderKey的请求
        return NO;
    }
    if ([self p_isFilterWithUrlRequest:request]) {
        NSLog(@"can start %@", request.URL.absoluteString);
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    
    NSString *url = self.request.URL.absoluteString;//请求的链接
    HDWebURLProtocolCacheData *cacheData = [NSKeyedUnarchiver unarchiveObjectWithFile:[self p_filePathWithUrlString:url]];
    
    if ([self p_isUseCahceWithCacheData:cacheData]) {
        //有缓存并且缓存没过期
        if (cacheData.redirectRequest) {
            [self.client URLProtocol:self wasRedirectedToRequest:cacheData.redirectRequest redirectResponse:cacheData.response];
        } else  if (cacheData.response){
            [self.client URLProtocol:self didReceiveResponse:cacheData.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:cacheData.data];
            [self.client URLProtocolDidFinishLoading:self];
        }
    } else {
        NSMutableURLRequest *request = [self.request mutableCopySubstitute];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        [request setValue:@"test" forHTTPHeaderField:HDProtocolHttpHeaderKey];
        self.downloadTask = [self.session dataTaskWithRequest:request];
        [self.downloadTask resume];
    }
}

- (void)stopLoading {
    [self.downloadTask cancel];
    self.cacheData = nil;
    self.downloadTask = nil;
    self.response = nil;
}

#pragma mark - session delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    //处理重定向问题
    if (response != nil) {
        NSMutableURLRequest *redirectableRequest = [request mutableCopySubstitute];
        HDWebURLProtocolCacheData *cacheData = [[HDWebURLProtocolCacheData alloc] init];
        cacheData.data = self.cacheData;
        cacheData.response = response;
        cacheData.redirectRequest = redirectableRequest;
        [NSKeyedArchiver archiveRootObject:cacheData toFile:[self p_filePathWithUrlString:request.URL.absoluteString]];
        
        [self.client URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        completionHandler(request);
    } else {
        completionHandler(request);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
    self.cacheData = [NSMutableData data];
    self.response = response;
}

-  (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //下载过程中
    [self.client URLProtocol:self didLoadData:data];
    [self.cacheData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //    下载完成之后的处理
    if (error) {
        NSLog(@"error url = %@",task.currentRequest.URL.absoluteString);
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        //将数据的缓存归档存入到本地文件中
        NSLog(@"ok url = %@",task.currentRequest.URL.absoluteString);
        HDWebURLProtocolCacheData *cacheData = [[HDWebURLProtocolCacheData alloc] init];
        cacheData.data = [self.cacheData copy];
        cacheData.addDate = [NSDate date];
        cacheData.response = self.response;
        [NSKeyedArchiver archiveRootObject:cacheData toFile:[self p_filePathWithUrlString:self.request.URL.absoluteString]];
        [self.client URLProtocolDidFinishLoading:self];
    }
}

@end
