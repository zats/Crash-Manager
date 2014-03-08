//
//  CRMIssuesDefaultDataSource.h
//  CrashManager
//
//  Created by Sasha Zats on 3/8/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMIssuesDataSource.h"

@class CRMApplication;
@interface CRMIssuesDefaultDataSource : CRMIssuesDataSource

@property (nonatomic, strong) CRMApplication *application;

@end
