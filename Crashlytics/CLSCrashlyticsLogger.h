//
//  CLSCrashlyticsLogger.h
//  CrashManager
//
//  Created by Sasha Zats on 3/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "DDLog.h"

@interface CLSCrashlyticsLogger : DDAbstractLogger

+ (instancetype)sharedInstance;

@end
