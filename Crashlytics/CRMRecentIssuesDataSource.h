//
//  CRMRecentIssuesDataSource.h
//  CrashManager
//
//  Created by Sasha Zats on 3/8/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMIssuesDataSource.h"

@interface CRMRecentIssuesDataSource : CRMIssuesDataSource

@property (nonatomic, copy) NSArray *issues;

@end
