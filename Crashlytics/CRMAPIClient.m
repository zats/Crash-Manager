//
//  CRMAPIClient.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMAPIClient.h"

#import "NSURLRequest+CRMLogging.h"
#import "CRMAccount.h"
#import "CRMApplication.h"
#import "CRMBuild.h"
#import "CRMFilter.h"
#import "CRMRequestSerializer.h"
#import "CRMIncident.h"
#import "CRMIssue.h"
#import "CRMOrganization.h"
#import "CRMResponseSerializer.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

@interface CRMAPIClient ()
@end

@implementation CRMAPIClient

+ (instancetype)sharedInstance {
	static CRMAPIClient *apiClient;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NSURL URLWithString:@"https://api.crashlytics.com/"];
		apiClient = [[CRMAPIClient alloc] initWithBaseURL:baseURL];
	});
	return apiClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
	if (!self) {
		return nil;
	}
	[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
	self.requestSerializer = [CRMRequestSerializer serializer];
	self.responseSerializer = [CRMResponseSerializer serializer];
    
    // Network error tracking
    [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingTaskDidCompleteNotification object:Nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSURLSessionTask *task = [note object];
        NSError *error = [note userInfo][AFNetworkingTaskDidCompleteErrorKey];
        if (task && error && task.originalRequest) {
            DDLogError(@"Networking error occured; \nRequest: %@ \nError: %@", [task.originalRequest crm_cURLCommand], [error localizedDescription]);
        }
    }];
    
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation CRMAPIClient (CRMSession)

- (RACSignal *)createSessionWithAccount:(CRMAccount *)account {
	NSParameterAssert(account.email);
	NSParameterAssert(account.password);
	NSAssert(![account.objectID isTemporaryID], @"Account is not persisted");
	NSManagedObjectID *accountObjectID = account.objectID;
	RACReplaySubject *subject = [RACReplaySubject subject];
	NSDictionary *parameters = @{
		@"email" : account.email,
		@"password" : account.password
	};
	[self POST:@"api/v2/session" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
		CRMAccount *account = (CRMAccount *)[context objectRegisteredForID:accountObjectID];
		[account updateWithContentsOfDictionary:responseObject];
		[context MR_saveToPersistentStoreAndWait];
		
		[subject sendNext:[CRMAccount activeAccount]];
		[subject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[subject sendError:error];
	}];
	return subject;
}

@end

@implementation CRMAPIClient (CRMOrganization)

- (RACSignal *)applicationsForOrganization:(CRMOrganization *)organization {
	NSParameterAssert(organization.organizationID);
	NSString *orgnaizationID = organization.organizationID;
	RACReplaySubject *subject = [RACReplaySubject subject];
	[self GET:[NSString stringWithFormat:@"api/v2/organizations/%@/apps", organization.organizationID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		CRMOrganization *organization = [CRMOrganization MR_findFirstByAttribute:CRMOrganizationAttributes.organizationID
																	   withValue:orgnaizationID];
		[organization updateApplicationsWithContentsOfArray:responseObject];
		[organization.managedObjectContext MR_saveToPersistentStoreAndWait];

		[subject sendNext:organization];
		[subject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[subject sendError:error];
	}];
	return subject;
}

- (RACSignal *)organizations {
	RACReplaySubject *subject = [RACReplaySubject subject];
	[self GET:@"api/v2/organizations" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[[CRMAccount activeAccount] updateOrganizationsWithContentsOfArray:responseObject];
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
		[subject sendNext:[CRMAccount activeAccount].organizations];
		[subject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[subject sendError:error];
	}];
	return subject;
}

@end

@implementation CRMAPIClient (CRMBuild)

- (RACSignal *)buildsForApplication:(CRMApplication *)application {
	NSParameterAssert(application.applicationID);
	NSAssert(application.organization.organizationID, @"Organization is not set for the application %@", application);
	NSString *applicationID = application.applicationID;
	NSString *path = [NSString stringWithFormat:@"api/v2/organizations/%@/apps/%@/builds", application.organization.organizationID, application.applicationID];
	RACReplaySubject *subject = [RACReplaySubject subject];
	[self GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		CRMApplication *application = [CRMApplication MR_findFirstByAttribute:CRMApplicationAttributes.applicationID
																	withValue:applicationID];
		[application updateBuildsWithContentsOfArray:responseObject];
		[application.managedObjectContext MR_saveToPersistentStoreAndWait];
		
		[subject sendNext:application.builds];
		[subject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[subject sendError:error];
	}];
	return subject;
}

- (RACSignal *)setReportCollectionForBuild:(CRMBuild *)build
								   enabled:(BOOL)enabled {
	NSParameterAssert(build.buildID);
	NSParameterAssert(build.application.organization.organizationID);
	NSParameterAssert(build.application.applicationID);
	RACReplaySubject *subject = [RACReplaySubject subject];
	NSString *path = [NSString stringWithFormat:@"api/v2/organizations/%@/apps/%@", build.application.organization.organizationID, build.application.applicationID];
	NSDictionary *parameters = @{ @"build_opts": @{ build.buildID : @{ @"collect_crash_reports":@(enabled)}}};
	[self PUT:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[subject sendNext:nil];
		[subject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[subject sendError:error];
	}];
	return subject;
}

@end

@implementation CRMAPIClient (CRMIssues)

- (RACSignal *)issuesForApplication:(CRMApplication *)application {
	NSParameterAssert(application.applicationID);
	NSParameterAssert(application.organization.organizationID);
	
	NSString *applicationID = application.applicationID;
	NSString *path = [NSString stringWithFormat:@"api/v2/organizations/%@/apps/%@/issues.json", application.organization.organizationID, application.applicationID];
	NSMutableDictionary *parameters = [@{ @"event_type_equals" : @"all" } mutableCopy];
	parameters[@"status_equals"] = application.filter.issueStatus ?: CRMFilterIssueStatusAll;
	if ([application.filter isBuildFilterSet]) {
		parameters[@"build_equals"] = application.filter.build.buildID;
	}
	if ([application.filter isTimeRangeFilterEnabled]) {
		NSTimeInterval olderThan = application.filter.issueOlderThenValue;
		NSTimeInterval newerThan = application.filter.issueNewerThenValue;
		parameters[@"created_lte"] = @(floor([[NSDate dateWithTimeIntervalSinceNow:olderThan] timeIntervalSince1970]));
		parameters[@"created_gte"] = @(floor([[NSDate dateWithTimeIntervalSinceNow:newerThan] timeIntervalSince1970]));
	}
	
	return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		AFHTTPRequestOperation *operation = [self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
			CRMApplication *application = [CRMApplication MR_findFirstByAttribute:CRMApplicationAttributes.applicationID
																		withValue:applicationID];
			[application updateIssuesWithContentsOfArray:responseObject];
			[application.managedObjectContext MR_saveToPersistentStoreAndWait];
			NSArray *issueIDs = [responseObject valueForKey:@"id"];
			[subscriber sendNext:issueIDs];
			[subscriber sendCompleted];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[subscriber sendError:error];
		}];
		
		return [RACDisposable disposableWithBlock:^{
			[operation cancel];
		}];
	}];
}

- (RACSignal *)latestIncidentForIssue:(CRMIssue *)issue {
	NSParameterAssert(issue.issueID);
	NSParameterAssert(issue.application.organization.organizationID);
	NSParameterAssert(issue.application.applicationID);
	NSString *issueID = issue.issueID;
	RACReplaySubject *replaySubject = [RACReplaySubject subject];
	NSString *path = [NSString stringWithFormat:@"api/v2/organizations/%@/apps/%@/issues/%@", issue.application.organization.organizationID, issue.application.applicationID, issueID];
	NSDictionary *parameters = nil;
	[self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		CRMIssue *issue = [CRMIssue MR_findFirstByAttribute:CRMIssueAttributes.issueID
												  withValue:issueID];
		[issue updateWithContentsOfDictionary:responseObject];
		[issue.managedObjectContext MR_saveToPersistentStoreAndWait];
		
		[replaySubject sendNext:issue];
		[replaySubject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[replaySubject sendError:error];
	}];
	return replaySubject;
}

- (RACSignal *)detailsForIssue:(CRMIssue *)issue {
	NSParameterAssert(issue.issueID);
	NSParameterAssert(issue.latestIncidentID);
	NSParameterAssert(issue.application.organization.organizationID);
	NSParameterAssert(issue.application.applicationID);
	NSString *issueID = issue.issueID;
	NSString *path = [NSString stringWithFormat:@"api/v2/organizations/%@/apps/%@/issues/%@/clsessions/%@", issue.application.organization.organizationID, issue.application.applicationID, issue.issueID, issue.latestIncidentID];
	NSDictionary *parameters = @{ @"suppress_previous_next" : @YES };
	RACReplaySubject *subject = [RACReplaySubject subject];
	[self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		CRMSession *session = [CRMSession parseFromData:responseObject];
		CRMIssue *issue = [CRMIssue MR_findFirstByAttribute:CRMIssueAttributes.issueID
												  withValue:issueID];
		issue.lastSession = session;
		[issue.managedObjectContext MR_saveToPersistentStoreAndWait];
		[subject sendNext:session];
		[subject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[subject sendError:error];
	}];
	return subject;
}

- (RACSignal *)setResolved:(BOOL)resolved
				  forIssue:(CRMIssue *)issue {
	NSDate *oldResolvedAtValue = [issue.resolvedAt copy];
	if (resolved) {
		issue.resolvedAt = [NSDate date];
	} else {
		issue.resolvedAt = nil;
	}
	[issue.managedObjectContext MR_saveToPersistentStoreAndWait];
	NSString *issueID = issue.issueID;
	NSParameterAssert(issue);
	NSAssert([issueID length], @"Invalid issue ID");
	NSAssert([issue.application.applicationID length], @"Invalid application ID");
	NSAssert([issue.application.organization.organizationID length], @"Invalid organization ID");
	RACReplaySubject *subject = [RACReplaySubject subject];
	NSString *path = [NSString stringWithFormat:@"api/v2/organizations/%@/apps/%@/issues/%@", issue.application.organization.organizationID, issue.application.applicationID, issue.issueID];
	id resolvedAt = resolved ? [[CRMIssue formatter] stringFromDate:issue.resolvedAt] : [NSNull null];
	NSDictionary *parameters = @{ @"resolved_at" : resolvedAt };
	[self PUT:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[subject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		CRMIssue *issue = [CRMIssue MR_findFirstByAttribute:CRMIssueAttributes.issueID
												  withValue:issueID];
		issue.resolvedAt = oldResolvedAtValue;
		[issue.managedObjectContext MR_saveToPersistentStoreAndWait];
		[subject sendError:error];
	}];
	return subject;
}

@end
