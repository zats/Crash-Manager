//
//  CLSCrashlyticsLogger.m
//  CrashManager
//
//  Created by Sasha Zats on 3/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CLSCrashlyticsLogger.h"

#import <Crashlytics/Crashlytics.h>

@interface CLSCrashlyticsLogger ()

@end

@implementation CLSCrashlyticsLogger

+ (instancetype)sharedInstance {
	static CLSCrashlyticsLogger *instnace;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instnace = [[CLSCrashlyticsLogger alloc] init];
	});
	return instnace;
}

#pragma mark - DDLogger

- (void)logMessage:(DDLogMessage *)logMessage {
	CLSLog(logMessage->logMsg);
}

@end
