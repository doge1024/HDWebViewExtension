//
//  HDAppDelegate.m
//  HDWebViewExtension
//
//  Created by harddog on 08/20/2018.
//  Copyright (c) 2018 harddog. All rights reserved.
//

#import "HDAppDelegate.h"
#import <HDWebViewExtension/HDWebViewExtension.h>
#import "ZHWebView.h"
#import <objc/runtime.h>

@implementation HDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [HDWebViewExtension startPreloadWithWebViewClass:[ZHWebView class]];
    [HDWebViewExtension startCacheWebRequest];
    [HDAppDelegate exchange];
    return YES;
}


+ (void)exchange {
    
    Class WKCustomProtocolClass = object_getClass(NSClassFromString(@"HDWebURLProtocol")); // HDWebURLProtocol is ok
    
    SEL canInitWithRequest = NSSelectorFromString(@"canInitWithRequest:");
    SEL af_canInitWithRequest = NSSelectorFromString(@"fix_canInitWithRequest:");
    
    BOOL add1 = class_addMethod(WKCustomProtocolClass,
                                canInitWithRequest,
                                class_getMethodImplementation(WKCustomProtocolClass, canInitWithRequest),
                                "B@:@");
    
    BOOL add2 = class_addMethod(WKCustomProtocolClass,
                                af_canInitWithRequest,
                                (IMP)af_canInitWithRequest2,
                                "B@:@");
    
    NSLog(@"%d,%d", add1, add2);
    
    Method orgi = class_getClassMethod(WKCustomProtocolClass, canInitWithRequest);
    Method after = class_getClassMethod(WKCustomProtocolClass, af_canInitWithRequest);
    
    method_exchangeImplementations(orgi, after);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

BOOL af_canInitWithRequest2(id sender, SEL cmd, NSURLRequest *req) {
    SEL canInitWithRequest = NSSelectorFromString(@"fix_canInitWithRequest:");
    return [sender performSelector:canInitWithRequest withObject:req];
}

#pragma clang diagnostic pop


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
