//
//  CLSAPIClient.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@class CLSAccount, CLSApplication, CLSBuild, CLSIssue, CLSOrganization;
@interface CLSAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedInstance;

    
@end

@interface CLSAPIClient (CLSSession)

- (RACSignal *)createSessionWithAccount:(CLSAccount *)account;

@end

@interface CLSAPIClient (CLSOrganization)

- (RACSignal *)applicationsForOrganization:(CLSOrganization *)organization;
- (RACSignal *)organizations;

@end

@interface CLSAPIClient (CLSBuild)

- (RACSignal *)buildsForApplication:(CLSApplication *)application;
- (RACSignal *)setReportCollectionForBuild:(CLSBuild *)build
								   enabled:(BOOL)enabled;

@end

@interface CLSAPIClient (CLSIssues)

- (RACSignal *)issuesForApplication:(CLSApplication *)application;
- (RACSignal *)latestIncidentForIssue:(CLSIssue *)issue;
- (RACSignal *)detailsForIssue:(CLSIssue *)issue;
- (RACSignal *)setResolved:(BOOL)resolved
				  forIssue:(CLSIssue *)issue;

@end
