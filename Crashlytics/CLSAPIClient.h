//
//  CLSAPIClient.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@class CRMAccount, CRMApplication, CRMBuild, CRMIssue, CRMOrganization;
@interface CLSAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedInstance;

    
@end

@interface CLSAPIClient (CRMSession)

- (RACSignal *)createSessionWithAccount:(CRMAccount *)account;

@end

@interface CLSAPIClient (CLSOrganization)

- (RACSignal *)applicationsForOrganization:(CRMOrganization *)organization;
- (RACSignal *)organizations;

@end

@interface CLSAPIClient (CLSBuild)

- (RACSignal *)buildsForApplication:(CRMApplication *)application;
- (RACSignal *)setReportCollectionForBuild:(CRMBuild *)build
								   enabled:(BOOL)enabled;

@end

@interface CLSAPIClient (CLSIssues)

- (RACSignal *)issuesForApplication:(CRMApplication *)application;
- (RACSignal *)latestIncidentForIssue:(CRMIssue *)issue;
- (RACSignal *)detailsForIssue:(CRMIssue *)issue;
- (RACSignal *)setResolved:(BOOL)resolved
				  forIssue:(CRMIssue *)issue;

@end
