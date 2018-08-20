#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HDWebViewExtension.h"
#import "HDWebViewPool.h"
#import "HDWebURLProtocol.h"
#import "NSURLProtocol+HDWebKitSupport.h"

FOUNDATION_EXPORT double HDWebViewExtensionVersionNumber;
FOUNDATION_EXPORT const unsigned char HDWebViewExtensionVersionString[];

