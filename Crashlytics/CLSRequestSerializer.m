//
//  CLSHTTPRequestSerializer.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/8/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSRequestSerializer.h"

#import "CLSAccount.h"

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
								parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [super requestWithMethod:method
												  URLString:URLString
												 parameters:parameters];

	NSString *developerToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"CrashlyticsDeveloperToken"];
	[request setValue:developerToken
   forHTTPHeaderField:@"X-CRASHLYTICS-DEVELOPER-TOKEN"];
	
	if ([[CLSAccount activeAccount] canRestoreSession]) {
		[request setValue:[CLSAccount activeAccount].token
	   forHTTPHeaderField:@"X-CRASHLYTICS-ACCESS-TOKEN"];
	}
#ifdef DEBUG
	NSLog(@"%@ %@\n%@\n%@", request.HTTPMethod, request.URL, [request allHTTPHeaderFields], parameters ?: @"");
#endif
	return request;
}

@end
