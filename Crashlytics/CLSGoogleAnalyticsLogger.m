//
//  CLSGoogleAnalyticsLogger.m
//  CrashManager
//
//  Created by Sasha Zats on 2/21/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CLSGoogleAnalyticsLogger.h"

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAILogger.h>

@interface CLSGoogleAnalyticsLogger ()

@end

@implementation CLSGoogleAnalyticsLogger

#pragma mark - Initialization

+ (instancetype)sharedInstance {
	static CLSGoogleAnalyticsLogger *instnace;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instnace = [[CLSGoogleAnalyticsLogger alloc] init];
	});
	return instnace;
}


#pragma mark - DDLogger

- (void)logMessage:(DDLogMessage *)logMessage {
	id<GAILogger> logger = self.logger ?: [GAI sharedInstance].logger;
	
	switch (logMessage->logLevel) {
		case LOG_LEVEL_INFO:
			[logger info:logMessage->logMsg];
			break;
			
		case LOG_LEVEL_WARN:
			[logger warning:logMessage->logMsg];
			break;
			
		case LOG_LEVEL_ERROR:
			[logger error:logMessage->logMsg];
			break;
			
		case LOG_LEVEL_DEBUG:
		case LOG_LEVEL_VERBOSE:
		default:
			[logger verbose:logMessage->logMsg];
			break;
	}
}

@end
