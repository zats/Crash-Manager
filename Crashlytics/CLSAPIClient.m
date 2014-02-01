//
//  CLSAPIClient.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSAPIClient.h"

#import "CLSAccount.h"
#import "CLSApplication.h"
#import "CLSBuild.h"
#import "CLSFilter.h"
#import "CLSRequestSerializer.h"
#import "CLSIncident.h"
#import "CLSIssue.h"
#import "CLSOrganization.h"
#import "CLSResponseSerializer.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

static NSString *CLSGANetworkErrorCategory = @"Network error";

@interface CLSAPIClient ()
@end

@implementation CLSAPIClient

+ (instancetype)sharedInstance {
	static CLSAPIClient *apiClient;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NSURL URLWithString:@"https://api.crashlytics.com/"];
		apiClient = [[CLSAPIClient alloc] initWithBaseURL:baseURL];
	});
	return apiClient;
}

// https://github.com/mattt/FormatterKit/blame/master/FormatterKit/TTTURLRequestFormatter.m#L45
+ (NSString *)cURLCommandFromURLRequest:(NSURLRequest *)request {
    NSMutableString *command = [NSMutableString stringWithString:@"curl"];
    
    [command appendFormat:@" -X %@", [request HTTPMethod]];
    
    if ([[request HTTPBody] length] > 0) {
        NSMutableString *HTTPBodyString = [[NSMutableString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
        [HTTPBodyString replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [HTTPBodyString replaceOccurrencesOfString:@"`" withString:@"\\`" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [HTTPBodyString replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [HTTPBodyString replaceOccurrencesOfString:@"$" withString:@"\\$" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [command appendFormat:@" -d \"%@\"", HTTPBodyString];
    }
    
    NSString *acceptEncodingHeader = [[request allHTTPHeaderFields] valueForKey:@"Accept-Encoding"];
    if ([acceptEncodingHeader rangeOfString:@"gzip"].location != NSNotFound) {
        [command appendString:@" --compressed"];
    }
    
    if ([request URL]) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[request URL]];
        for (NSHTTPCookie *cookie in cookies) {
            [command appendFormat:@" --cookie \"%@=%@\"", [cookie name], [cookie value]];
        }
    }
    
    for (id field in [request allHTTPHeaderFields]) {
        [command appendFormat:@" -H %@", [NSString stringWithFormat:@"'%@: %@'", field, [[request valueForHTTPHeaderField:field] stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"]]];
    }
    
    [command appendFormat:@" \"%@\"", [[request URL] absoluteString]];
    
    return [NSString stringWithString:command];
}

- (instancetype)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
	if (!self) {
		return nil;
	}
	[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
	self.requestSerializer = [CLSRequestSerializer serializer];
	self.responseSerializer = [CLSResponseSerializer serializer];
    
    // Network error tracking
    [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingTaskDidCompleteNotification object:Nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSURLSessionTask *task = [note object];
        NSError *error = [note userInfo][AFNetworkingTaskDidCompleteErrorKey];
        if (task && error && task.originalRequest) {
            DDLogError(@"Networking error occured; \nRequest: %@ \nError: %@", [[self class] cURLCommandFromURLRequest:task.originalRequest], [error localizedDescription]);
        }
    }];
    
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation CLSAPIClient (CLSSession)

- (RACSignal *)createSessionWithAccount:(CLSAccount *)account {
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
		CLSAccount *account = (CLSAccount *)[context objectRegisteredForID:accountObjectID];
		[account updateWithContentsOfDictionary:responseObject];
		[context MR_saveToPersistentStoreAndWait];
		
		[subject sendNext:[CLSAccount activeAccount]];
		[subject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[subject sendError:error];
	}];
	return subject;
}

@end

@implementation CLSAPIClient (CLSOrganization)

- (RACSignal *)applicationsForOrganization:(CLSOrganization *)organization {
	NSParameterAssert(organization.organizationID);
	NSString *orgnaizationID = organization.organizationID;
	RACReplaySubject *subject = [RACReplaySubject subject];
	[self GET:[NSString stringWithFormat:@"api/v2/organizations/%@/apps", organization.organizationID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		CLSOrganization *organization = [CLSOrganization MR_findFirstByAttribute:CLSOrganizationAttributes.organizationID
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
		[[CLSAccount activeAccount] updateOrganizationsWithContentsOfArray:responseObject];
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
		[subject sendNext:[CLSAccount activeAccount].organizations];
		[subject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[subject sendError:error];
	}];
	return subject;
}

@end

@implementation CLSAPIClient (CLSBuild)

- (RACSignal *)buildsForApplication:(CLSApplication *)application {
	NSParameterAssert(application.applicationID);
	NSAssert(application.organization.organizationID, @"Organization is not set for the application %@", application);
	NSString *applicationID = application.applicationID;
	NSString *path = [NSString stringWithFormat:@"api/v2/organizations/%@/apps/%@/builds", application.organization.organizationID, application.applicationID];
	RACReplaySubject *subject = [RACReplaySubject subject];
	[self GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		CLSApplication *application = [CLSApplication MR_findFirstByAttribute:CLSApplicationAttributes.applicationID
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

- (RACSignal *)setReportCollectionForBuild:(CLSBuild *)build
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

@implementation CLSAPIClient (CLSIssues)

- (RACSignal *)issuesForApplication:(CLSApplication *)application {
	NSParameterAssert(application.applicationID);
	NSParameterAssert(application.organization.organizationID);
	
	NSString *applicationID = application.applicationID;
	NSString *path = [NSString stringWithFormat:@"api/v2/organizations/%@/apps/%@/issues.json", application.organization.organizationID, application.applicationID];
	NSMutableDictionary *parameters = [@{ @"event_type_equals" : @"all" } mutableCopy];
	parameters[@"status_equals"] = application.filter.issueStatus ?: CLSFilterIssueStatusAll;
	if ([application.filter isBuildFilterSet]) {
		parameters[@"build_equals"] = application.filter.build.buildID;
	}
	if ([application.filter isTimeRangeFilterSet]) {
		NSTimeInterval olderThan = application.filter.issueOlderThenValue;
		NSTimeInterval newerThan = application.filter.issueNewerThenValue;
		parameters[@"created_lte"] = @(floor([[NSDate dateWithTimeIntervalSinceNow:olderThan] timeIntervalSince1970]));
		parameters[@"created_gte"] = @(floor([[NSDate dateWithTimeIntervalSinceNow:newerThan] timeIntervalSince1970]));
	}
	
	return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		AFHTTPRequestOperation *operation = [self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
			CLSApplication *application = [CLSApplication MR_findFirstByAttribute:CLSApplicationAttributes.applicationID
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

- (RACSignal *)latestIncidentForIssue:(CLSIssue *)issue {
	NSParameterAssert(issue.issueID);
	NSParameterAssert(issue.application.organization.organizationID);
	NSParameterAssert(issue.application.applicationID);
	NSString *issueID = issue.issueID;
	RACReplaySubject *replaySubject = [RACReplaySubject subject];
	NSString *path = [NSString stringWithFormat:@"api/v2/organizations/%@/apps/%@/issues/%@", issue.application.organization.organizationID, issue.application.applicationID, issueID];
	NSDictionary *parameters = nil;
	[self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		CLSIssue *issue = [CLSIssue MR_findFirstByAttribute:CLSIssueAttributes.issueID
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

- (RACSignal *)detailsForIssue:(CLSIssue *)issue {
	NSParameterAssert(issue.issueID);
	NSParameterAssert(issue.latestIncidentID);
	NSParameterAssert(issue.application.organization.organizationID);
	NSParameterAssert(issue.application.applicationID);
	NSString *issueID = issue.issueID;
	NSString *path = [NSString stringWithFormat:@"api/v2/organizations/%@/apps/%@/issues/%@/clsessions/%@", issue.application.organization.organizationID, issue.application.applicationID, issue.issueID, issue.latestIncidentID];
	NSDictionary *parameters = @{ @"suppress_previous_next" : @YES };
	RACReplaySubject *subject = [RACReplaySubject subject];
	[self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		CLSSession *session = [CLSSession parseFromData:responseObject];
		CLSIssue *issue = [CLSIssue MR_findFirstByAttribute:CLSIssueAttributes.issueID
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
				  forIssue:(CLSIssue *)issue {
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
	id resolvedAt = resolved ? [[CLSIssue formatter] stringFromDate:issue.resolvedAt] : [NSNull null];
	NSDictionary *parameters = @{ @"resolved_at" : resolvedAt };
	[self PUT:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		CLSIssue *issue = [CLSIssue MR_findFirstByAttribute:CLSIssueAttributes.issueID
//												  withValue:issueID];
//		[issue.managedObjectContext MR_saveToPersistentStoreAndWait];
		[subject sendCompleted];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		CLSIssue *issue = [CLSIssue MR_findFirstByAttribute:CLSIssueAttributes.issueID
												  withValue:issueID];
		issue.resolvedAt = oldResolvedAtValue;
		[issue.managedObjectContext MR_saveToPersistentStoreAndWait];
		[subject sendError:error];
	}];
	return subject;
}

@end
