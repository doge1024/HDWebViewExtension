//
//  HDWebViewPool.m
//  HDWebViewExtension
//
//  Created by lzh on 2018/8/20.
//

#import "HDWebViewPool.h"


#define LOCK(A) dispatch_semaphore_wait(A.lock, DISPATCH_TIME_FOREVER)
#define UNLOCK(A) dispatch_semaphore_signal(A.lock)

#if 1
#define NSLog(...) {}
#endif

@interface HDWebViewPool ()

@property(nonatomic, strong) NSMutableSet<__kindof WKWebView *> *reusableWebViewSet;

@property (nonatomic, copy) NSDictionary *webClassDict;

@property(nonatomic, strong) dispatch_semaphore_t lock;

@property (nonatomic, strong) id notification;

@end

@implementation HDWebViewPool

+ (instancetype)shareInstance {
    static dispatch_once_t once;
    static HDWebViewPool *webViewPool = nil;
    dispatch_once(&once,^{
        webViewPool = [[self alloc] init];
    });
    return webViewPool;
}

/**
 开始预加载webView
 */
+ (void)startPreload {
    [self startPreloadWithWebViewSet:nil];
}

/**
 开始预加载webView, {class: preloadCount}
 */
+ (void)startPreloadWithWebViewSet:(nullable NSDictionary *)webDict {
    [[self shareInstance] setWebClassDict:webDict];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            [self createWebViewIfNeed];
        });
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
        
        id notification = [[NSNotificationCenter defaultCenter]
                           addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                           object:nil
                           queue:[NSOperationQueue mainQueue]
                           usingBlock:^(NSNotification * _Nonnull note) {
                               CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
                               [[self shareInstance] _cleanAllReusableWebViews];
                               [[NSNotificationCenter defaultCenter] removeObserver:[[self shareInstance] notification] name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
                               [[self shareInstance] setNotification:nil];
                           }];
        [[self shareInstance] setNotification:notification];
    });
}

- (instancetype)init {
    if(self = [super init]){
        self.lock = dispatch_semaphore_create(1);
        self.reusableWebViewSet = [NSSet set].mutableCopy;
        self.maxReusedWebViewCount = 1;
    }
    return self;
}

+ (void)createWebViewIfNeed {
    if (![[self shareInstance] webViewClass]) {
        return;
    }
    // 即将进入休眠
    HDWebViewPool *this = [HDWebViewPool shareInstance];
    LOCK(this);
    WKWebView *webView = nil;
    if (this.reusableWebViewSet.count < this.maxReusedWebViewCount) {
        NSLog(@"this need create a reuse webview");
        webView = [this _createAWebView];
        if (webView) {
            [this.reusableWebViewSet addObject:webView];
        }
    }
    UNLOCK(this);
}

/**
 获取一个预加载的webView
 */
- (__kindof WKWebView *)getReusedWebView {
    WKWebView *webView = nil;
    LOCK(self);
    if (_reusableWebViewSet.count > 0) {
        webView = [_reusableWebViewSet anyObject];
        NSLog(@"get a reuse webview");
        [_reusableWebViewSet removeObject:webView];
    } else {
        webView = [self _createAWebView];
    }
    UNLOCK(self);
    
    return webView;
}

- (__kindof WKWebView *)_createAWebView {
    WKWebView *webView = nil;
    Class cls = self.webViewClass;
    if (cls == nil) {
        return nil;
    }
    if ([self.webViewClass respondsToSelector:@selector(createPreLoadWebView)]) {
        webView = [cls createPreLoadWebView];
    } else {
        webView = [[cls alloc] initWithFrame:CGRectZero];
    }
    return webView;
}

- (void)_cleanAllReusableWebViews {
    @autoreleasepool {
        [self.reusableWebViewSet removeAllObjects];
    }
}

- (void)dealloc {
    [self setNotification:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
