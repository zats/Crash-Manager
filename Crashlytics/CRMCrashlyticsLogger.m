//
//  CRMCrashlyticsLogger.m
//  CrashManager
//
//  Created by Sasha Zats on 3/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMCrashlyticsLogger.h"

#import <Crashlytics/Crashlytics.h>

@interface CRMCrashlyticsLogger ()

@end

@implementation CRMCrashlyticsLogger

+ (instancetype)sharedInstance {
	static CRMCrashlyticsLogger *instnace;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instnace = [[CRMCrashlyticsLogger alloc] init];
	});
	return instnace;
}

#pragma mark - DDLogger

- (void)logMessage:(DDLogMessage *)logMessage {
	CLSLog(logMessage->logMsg);
}

@end
