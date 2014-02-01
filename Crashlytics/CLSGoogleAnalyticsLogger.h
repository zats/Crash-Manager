//
//  CLSGoogleAnalyticsLogger.h
//  CrashManager
//
//  Created by Sasha Zats on 2/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "DDLog.h"

@interface CLSGoogleAnalyticsLogger : DDAbstractLogger

+ (instancetype)sharedInstance;

@end
