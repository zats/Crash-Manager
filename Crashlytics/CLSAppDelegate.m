//
//  CLSAppDelegate.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSAppDelegate.h"

#import "CLSConfiguration.h"
#import "CLSAnalyticsController.h"
#import <Crashlytics/Crashlytics.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface CLSAppDelegate () <CrashlyticsDelegate>
@end

@implementation CLSAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Initializar configuration
    [[CLSConfiguration sharedInstance] setup];

	// Crashlytics
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"CrashlyticsAPIKey"];
	[Crashlytics startWithAPIKey:apiKey];

	// Analytics
	[[CLSAnalyticsController sharedInstance] enableAnalyticsIfNeeded];

    // Configuration
	[[CLSConfiguration sharedInstance] updateConfigurationPlistWithCompletionHandler:^(NSDictionary *defaults, NSError *error) {
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
