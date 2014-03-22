//
//  CRMAPIClient.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@class CRMAccount, CRMApplication, CRMBuild, CRMIssue, CRMOrganization;
@interface CRMAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedInstance;

    
@end

@interface CRMAPIClient (CRMSession)

- (RACSignal *)createSessionWithAccount:(CRMAccount *)account;

@end

@interface CRMAPIClient (CRMOrganization)

- (RACSignal *)applicationsForOrganization:(CRMOrganization *)organization;
- (RACSignal *)organizations;

@end

@interface CRMAPIClient (CRMBuild)

- (RACSignal *)buildsForApplication:(CRMApplication *)application;
- (RACSignal *)setReportCollectionForBuild:(CRMBuild *)build
								   enabled:(BOOL)enabled;

@end

@interface CRMAPIClient (CRMIssues)

- (RACSignal *)issuesForApplication:(CRMApplication *)application;
- (RACSignal *)latestIncidentForIssue:(CRMIssue *)issue;
- (RACSignal *)detailsForIssue:(CRMIssue *)issue;
- (RACSignal *)setResolved:(BOOL)resolved
				  forIssue:(CRMIssue *)issue;

@end

@interface CRMAPIClient (CRMWebHook)

- (RACSignal *)validateWebhookForApplication:(CRMApplication *)application;
- (RACSignal *)setWebhookForApplication:(CRMApplication *)application;

@end
