//
//  CRMResponseSerializer.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/19/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMResponseSerializer.h"

#import "CRMError.h"
#import "CRMAccount.h"

static inline NSArray *CRMSimplifyArray(NSArray *array);
static inline NSDictionary *CRMSimplifyDictionary(NSDictionary *dictionary);

static inline NSArray *CRMSimplifyArray(NSArray *array) {
	NSMutableArray *result = [array mutableCopy];
	[array enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
		NSCAssert((object != [NSNull null]), @"Don't know what to do with [Null null] in the array %@", array);
		
		if ([object isKindOfClass:[NSArray class]]) {
			[result replaceObjectAtIndex:idx
							  withObject:CRMSimplifyArray(object)];
		} else if ([object isKindOfClass:[NSDictionary class]]) {
			[result replaceObjectAtIndex:idx
							  withObject:CRMSimplifyDictionary(object)];
		}
	}];
	return [result copy];
}

static inline NSDictionary *CRMSimplifyDictionary(NSDictionary *dictionary) {
	__block NSMutableDictionary *result = [dictionary mutableCopy];
	for (NSString *key in dictionary) {
		if (result[key] == [NSNull null]) {
			[result removeObjectForKey:key];
		} else if ([result[key] isKindOfClass:[NSDictionary class]]) {
			result[key] = CRMSimplifyDictionary(dictionary[key]);
		} else if ([result[key] isKindOfClass:[NSArray class]]) {
			result[key] = CRMSimplifyArray(dictionary[key]);
		}
	}
	return [result copy];
}

@interface CRMResponseSerializer ()

@end

@implementation CRMResponseSerializer

- (instancetype)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	self.acceptableContentTypes = [NSSet setWithObjects:@"application/octet-stream", @"application/json", nil];
	
	return self;
}

- (id)responseObjectForResponse:(NSURLResponse *)response
						   data:(NSData *)data
						  error:(NSError *__autoreleasing *)error {
#ifdef DEBUG
	NSLog(@"%@\n%@\n%@", response.URL,
		  [((NSHTTPURLResponse *)response) allHeaderFields],
		  data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"");
#endif    
	BOOL isAuthenticationError = NO;
	BOOL isErrorResponse = NO;
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSString *contentType = [(NSHTTPURLResponse *)response allHeaderFields][@"content-type"];
		if ([contentType isEqualToString:@"application/octet-stream"]) {
			return data;
		}
		
		NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
		isErrorResponse = ![self.acceptableStatusCodes containsIndex:statusCode];
		isAuthenticationError = (statusCode == 401 ||
								 statusCode == 104);
	}
	
	if (isAuthenticationError) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[CRMAccount setCurrentAccount:nil];
		});
	}
	
	id result = [super responseObjectForResponse:response
											data:data
										   error:error];
	
	if (isErrorResponse) {
		// an error message?
		if (error) {
            NSDictionary *userInfo = result[@"message"] ? @{ NSLocalizedDescriptionKey : result[@"message"] } : nil;
			*error = [NSError errorWithDomain:CRMErrorDomain
										 code:((NSHTTPURLResponse *)response).statusCode
									 userInfo:userInfo];
		}
		return nil;
	}

	if ([result isKindOfClass:[NSDictionary class]]) {
		result = CRMSimplifyDictionary(result);
	} else if ([result isKindOfClass:[NSArray class]]) {
		result = CRMSimplifyArray(result);
	}
	return result;
}

@end
