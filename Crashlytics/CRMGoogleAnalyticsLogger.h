//
//  CLSGoogleAnalyticsLogger.h
//  CrashManager
//
//  Created by Sasha Zats on 2/21/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "DDLog.h"

@protocol GAILogger;
@interface CRMGoogleAnalyticsLogger : DDAbstractLogger

+ (instancetype)sharedInstance;

@property (nonatomic, weak) id<GAILogger> logger;

@end
