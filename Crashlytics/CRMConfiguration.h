//
//  CLSSettings.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CLSSettingsUpdateHandler)(NSDictionary *defaults, NSError *error);

@interface CRMConfiguration : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSURL *signUpURL;
@property (nonatomic, readonly) NSURL *forgotPasswordURL;

/**
 Runs through initial setup of the configuration: sets up logger and the
 */
- (void)setup;

//
- (void)updateConfigurationPlistWithCompletionHandler:(CLSSettingsUpdateHandler)completion;

@end

@interface CRMConfiguration (CLSMarketing)

- (NSURL *)marketingURL;
- (NSString *)appDisplayName;

@end

@interface CRMConfiguration (CLSOpenSource)

- (NSURL *)implementationURLForClass:(Class)className;
- (NSURL *)interfaceURLForClass:(Class)className;
- (NSURL *)gitHubPageURL;

@end
