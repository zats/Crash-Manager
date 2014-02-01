//
//  CLSGoogleAnalyticsLogger.m
//  CrashManager
//
//  Created by Sasha Zats on 2/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CLSGoogleAnalyticsLogger.h"

#import <GoogleAnalytics-iOS-SDK/GAI.h>

@interface CLSGoogleAnalyticsLogger ()

@end

@implementation CLSGoogleAnalyticsLogger

+ (instancetype)sharedInstance {
    static CLSGoogleAnalyticsLogger *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = logMessage->logMsg;
    
    if (self->formatter) {
        logMsg = [self->formatter formatLogMessage:logMessage];
    }
    
    if (logMsg) {
        id<GAILogger> logger = [GAI sharedInstance].logger;

        switch (logMessage->logLevel) {
            case LOG_LEVEL_ERROR:
                [logger error:logMsg];
                break;
                
            case LOG_LEVEL_WARN:
                [logger warning:logMsg];
                break;
                
            case LOG_LEVEL_INFO:
                [logger info:logMsg];
                break;
                
            default:
                [logger verbose:logMsg];
                break;
        }
    }
}

@end
