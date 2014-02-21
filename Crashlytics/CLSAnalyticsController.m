//
//  CLSAnalyticsController.m
//  CrashManager
//
//  Created by Sasha Zats on 2/21/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CLSAnalyticsController.h"

#import "CLSConstants.h"
#import "CLSGoogleAnalyticsLogger.h"
#import <Appsee/Appsee.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAILogger.h>

@interface CLSAnalyticsController ()
@property (nonatomic, assign) BOOL appseeEnabled;
@property (nonatomic, assign) BOOL googleAnalyticsEnabled;
@end

@implementation CLSAnalyticsController

#pragma mark - Initialization

+ (instancetype)sharedInstance {
	static CLSAnalyticsController *instnace;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instnace = [[CLSAnalyticsController alloc] init];
	});
	return instnace;
}

- (instancetype)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	RACSignal *userDefaultsDidChangeSignal = [[NSNotificationCenter defaultCenter] rac_addObserverForName:NSUserDefaultsDidChangeNotification
																								   object:nil];
	@weakify(self);
	[userDefaultsDidChangeSignal subscribeNext:^(NSNotification *notification) {
		@strongify(self);
		[self enableAnalyticsIfNeeded];
	}];

	return self;
}

#pragma mark - Public

- (void)enableAnalyticsIfNeeded {
	[self _enableAnalyticsWithConfiguration:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
}

#pragma mark - Private

- (void)_enableAnalyticsWithConfiguration:(NSDictionary *)configuration {
	BOOL isAppseeEnabled = [configuration[CLSAppseeEnabledKey] boolValue];
	BOOL isGoogleAnalyticsEnabled = [configuration[CLSGoogleAnalyticsEnabledKey] boolValue];
	if (self.appseeEnabled == isAppseeEnabled &&
		self.googleAnalyticsEnabled == isGoogleAnalyticsEnabled) {
		return;
	}
	
	// Google Analytics
	if (self.googleAnalyticsEnabled != isGoogleAnalyticsEnabled) {
		[self _setGoogleAnalyticsEnabled:isGoogleAnalyticsEnabled];
	}
	
	// Appsee
	if (self.appseeEnabled != isAppseeEnabled) {
		[self _setAppseeEnabled:isAppseeEnabled];
	}
}

- (void)_setGoogleAnalyticsEnabled:(BOOL)isGoogleAnalyticsEnabled {
	self.googleAnalyticsEnabled = isGoogleAnalyticsEnabled;
	
	// Google Analytics
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	if (!tracker) {
		tracker = [[GAI sharedInstance] trackerWithTrackingId:CLSGoogleAnalyticsIdenitifer];
	}
	
	if (isGoogleAnalyticsEnabled) {
		[GAI sharedInstance].optOut = NO;
		[DDLog addLogger:[CLSGoogleAnalyticsLogger sharedInstance]];
	} else {
		[GAI sharedInstance].optOut = YES;
		[DDLog removeLogger:[CLSGoogleAnalyticsLogger sharedInstance]];
	}
#ifdef DEBUG
	[GAI sharedInstance].dryRun = YES;
	[GAI sharedInstance].logger.logLevel = kGAILogLevelVerbose;
#endif
	DDLogVerbose(@"Google Analytics is %@", isGoogleAnalyticsEnabled ? @"enabled" : @"disabled");
}

- (void)_setAppseeEnabled:(BOOL)isAppseeEnabled {
	self.appseeEnabled = isAppseeEnabled;
	
	if (isAppseeEnabled) {
		[Appsee start:CLSAppseeAPIKey];
	} else {
		[Appsee stopAndUpload];
	}
	DDLogVerbose(@"Appsee analytics is %@", isAppseeEnabled ? @"enabled" : @"disabled");
}

@end
