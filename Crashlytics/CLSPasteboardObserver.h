//
//  CLSPasteboardObserver.h
//  Crash Manager
//
//  Created by Sasha Zats on 1/4/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLSPasteboardObserver : NSObject

+ (instancetype)sharedInstance;

- (void)startObservingParsteboardWithNavigationController:(UINavigationController *)navigationController;
- (void)stopObservingPasteboard;

@end
