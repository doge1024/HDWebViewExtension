# HDWebViewExtension

[![CI Status](https://img.shields.io/travis/harddog/HDWebViewExtension.svg?style=flat)](https://travis-ci.org/harddog/HDWebViewExtension)
[![Version](https://img.shields.io/cocoapods/v/HDWebViewExtension.svg?style=flat)](https://cocoapods.org/pods/HDWebViewExtension)
[![License](https://img.shields.io/cocoapods/l/HDWebViewExtension.svg?style=flat)](https://cocoapods.org/pods/HDWebViewExtension)
[![Platform](https://img.shields.io/cocoapods/p/HDWebViewExtension.svg?style=flat)](https://cocoapods.org/pods/HDWebViewExtension)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

HDWebViewExtension is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HDWebViewExtension'
```

## Run Demo
查看 HDAppDelegate.m， 通过 set use YES or NO, 来查看效果

## Use
```
#import <HDWebViewExtension/HDWebViewExtension.h>

[HDWebViewExtension startPreloadWithWebViewClass:[ZHWebView class]];
[HDWebViewExtension startCacheWebRequest];
```

## Author

harddog, 867129306@qq.com

## License

HDWebViewExtension is available under the MIT license. See the LICENSE file for more info.
