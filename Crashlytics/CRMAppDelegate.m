//
//  CRMAppDelegate.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMAppDelegate.h"

#import "CRMConfiguration.h"
#import "CRMAnalyticsController.h"
#import <Crashlytics/Crashlytics.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface CRMAppDelegate () <CrashlyticsDelegate>
@end

@implementation CRMAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Initializar configuration
    [[CRMConfiguration sharedInstance] setup];

	// Crashlytics
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"CrashlyticsAPIKey"];
	[Crashlytics startWithAPIKey:apiKey];

	// Analytics
	[[CRMAnalyticsController sharedInstance] enableAnalyticsIfNeeded];

    // Configuration
	[[CRMConfiguration sharedInstance] updateConfigurationPlistWithCompletionHandler:^(NSDictionary *defaults, NSError *error) {
		if (error) {
            DDLogError(@"Failed to fetch remote plist: %@", error);
		}
	}];
	
    // Core Data stack
	[MagicalRecord setupAutoMigratingCoreDataStack];
	[MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
	[MagicalRecord setErrorHandlerTarget:self action:@selector(_magicalRecordErrorHandler:)];
	
	self.window.tintColor = [UIColor colorWithRed:0.706 green:0.141 blue:0.063 alpha:1.000];
	
    return YES;
}

#pragma mark - Private

- (void)_magicalRecordErrorHandler:(NSError *)error {
	DDLogError(@"Core Data error: %@", error);
}

@end
