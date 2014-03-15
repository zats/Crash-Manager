//
//  CRMDefines.h
//  CrashManager
//
//  Created by Sasha Zats on 2/22/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import <Foundation/Foundation.h>


// Cocoa Lumberjack
#ifdef DEBUG
    static const int ddLogLevel = LOG_LEVEL_INFO;
#else
    static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

// Compiler-backed keypath, source: https://gist.github.com/kyleve/8213806
#ifdef DEBUG
    #define SQKeyPath(object, keyPath) ({ if (NO) { (void)((object).keyPath); } @#keyPath; })
#else 
    #define SQKeyPath(object, keyPath) ({ @#keyPath; })
#endif

#define SQSelfKeyPath(keyPath) SQKeyPath(self, keyPath)
#define SQTypedKeyPath(ObjectClass, keyPath) SQKeyPath(((ObjectClass *)nil), keyPath)
#define SQProtocolKeyPath(Protocol, keyPath) SQKeyPath(((id <Protocol>)nil), keyPath)

// ZAssert & co., source http://www.cimgf.com/2010/05/02/my-current-prefix-pch-file/
#ifdef DEBUG
    #define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
    #ifndef NS_BLOCK_ASSERTIONS
        #define NS_BLOCK_ASSERTIONS
    #endif
    #define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

#define ZAssert(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)
