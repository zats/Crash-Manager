//
//  CLSDefines.h
//  CrashManager
//
//  Created by Sasha Zats on 2/22/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

// Source: https://gist.github.com/kyleve/8213806

/**
 Provides the ability to verify key paths at compile time.
 
 If "keyPath" does not exist, a compile-time error will be generated.
 
 Example:
 // Verifies "isFinished" exists on "operation".
 NSString *key = SQKeyPath(operation, isFinished);
 
 // Verifies "isFinished" exists on self.
 NSString *key = SQSelfKeyPath(isFinished);
 
 // Verifies "isFinished" exists on instances of NSOperation.
 NSString *key = SQTypedKeyPath(NSOperation, isFinished);
 */
#define SQKeyPath(object, keyPath) ({ if (NO) { (void)((object).keyPath); } @#keyPath; })

#define SQSelfKeyPath(keyPath) SQKeyPath(self, keyPath)
#define SQTypedKeyPath(ObjectClass, keyPath) SQKeyPath(((ObjectClass *)nil), keyPath)
#define SQProtocolKeyPath(Protocol, keyPath) SQKeyPath(((id <Protocol>)nil), keyPath)
