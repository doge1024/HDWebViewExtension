//
//  ZHWebView.m
//  ZHWebView_Example
//
//  Created by lzh on 2018/8/16.
//  Copyright © 2018年 harddog. All rights reserved.
//

#import "ZHWebView.h"

@implementation ZHWebView

+ (instancetype)createPreLoadWebView;{
    return [[ZHWebView alloc] init];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
