//
//  CLSSettings.h
//  Crashlytics
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CLSSettingsUpdateHandler)(NSDictionary *defaults, NSError *error);

@interface CLSConfiguration : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSURL *signUpURL;
@property (nonatomic, readonly) NSURL *forgotPasswordURL;

- (NSURL *)implementationURLForClass:(Class)className;
- (NSURL *)interfaceURLForClass:(Class)className;

- (void)updateConfigurationPlistWithCompletionHandler:(CLSSettingsUpdateHandler)completion;

@end
