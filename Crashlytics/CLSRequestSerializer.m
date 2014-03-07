//
//  CLSHTTPRequestSerializer.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/8/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSRequestSerializer.h"

#import "NSURLRequest+CRMLogging.h"
#import "CRMAccount.h"

@interface CLSRequestSerializer ()

@end

@implementation CLSRequestSerializer

- (instancetype)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	[self setValue:@"application/json"
forHTTPHeaderField:@"Accept"];
		
	return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
								 URLString:(NSString *)URLString
								parameters:(NSDictionary *)parameters
									 error:(NSError *__autoreleasing *)error {
	NSMutableURLRequest *request = [super requestWithMethod:method
												  URLString:URLString
												 parameters:parameters
													  error:error];

	NSString *developerToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"CrashlyticsDeveloperToken"];
	[request setValue:developerToken
   forHTTPHeaderField:@"X-CRASHLYTICS-DEVELOPER-TOKEN"];
	
	if ([[CRMAccount activeAccount] canRestoreSession]) {
		[request setValue:[CRMAccount activeAccount].token
	   forHTTPHeaderField:@"X-CRASHLYTICS-ACCESS-TOKEN"];
	}
    DDLogVerbose(@"%@", [request cls_cURLCommand]);
	return request;
}

@end
