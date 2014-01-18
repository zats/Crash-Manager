//
//  CLSSettings.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSConfiguration.h"

#import <GroundControl/NSUserDefaults+GroundControl.h>

@interface CLSConfiguration ()
@end

@implementation CLSConfiguration

+ (instancetype)sharedInstance {
	static CLSConfiguration *settings;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		settings = [[CLSConfiguration alloc] init];
	});
	return settings;
}

+ (NSString *)configurationPlistPath {
	return [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"configuration.plist"];
}

- (instancetype)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	NSString *conigurationPlistPath = [[self class] configurationPlistPath];
	// If plist doesn't exist at target location, copy it from the package
	if (![[NSFileManager defaultManager] fileExistsAtPath:conigurationPlistPath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:[conigurationPlistPath stringByDeletingLastPathComponent]
								  withIntermediateDirectories:YES
												   attributes:nil
														error:nil];
		NSString *packagedPlist = [[NSBundle mainBundle] pathForResource:@"configuration"
																  ofType:@"plist"];
		[[NSFileManager defaultManager] copyItemAtPath:packagedPlist
												toPath:conigurationPlistPath
												 error:nil];
	}
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:conigurationPlistPath];
	[[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:dictionary];
	
	return self;
}

- (void)updateConfigurationPlistWithCompletionHandler:(CLSSettingsUpdateHandler)completion {
	NSURL *URL = [NSURL URLWithString:@"http://crashlytics-ios.herokuapp.com/configuration.plist"];
	[[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:URL success:^(NSDictionary *defaults) {
		NSData *data = [NSPropertyListSerialization dataFromPropertyList:defaults
																  format:NSPropertyListBinaryFormat_v1_0
														errorDescription:nil];
		[data writeToFile:[[self class] configurationPlistPath]
			   atomically:YES];
									
		completion(defaults, nil);
	} failure:^(NSError *error) {
		completion(nil, error);
	}];
}

- (NSURL *)signUpURL {
	return [NSURL URLWithString: [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CrashlyticsLinks.signUp"]];
}

- (NSURL *)forgotPasswordURL {
	return [NSURL URLWithString: [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CrashlyticsLinks.forgotPassword"]];
}

@end
