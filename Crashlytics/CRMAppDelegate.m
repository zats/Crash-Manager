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
#import <Parse/Parse.h>

@interface CRMAppDelegate () <CrashlyticsDelegate>
@end

@implementation CRMAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.tintColor = [UIColor colorWithRed:0.706 green:0.141 blue:0.063 alpha:1.000];

	// Initializar configuration
    [[CRMConfiguration sharedInstance] setup];    

    // Crashlytics
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"CrashlyticsAPIKey"];
	[Crashlytics startWithAPIKey:apiKey];

	// Analytics
	[[CRMAnalyticsController sharedInstance] enableAnalyticsIfNeeded];

    // Configuration2
	[[CRMConfiguration sharedInstance] updateConfigurationPlistWithCompletionHandler:^(NSDictionary *defaults, NSError *error) {
		if (error) {
            DDLogError(@"Failed to fetch remote plist: %@", error);
		}
	}];
	
    // Core Data stack
	[MagicalRecord setupAutoMigratingCoreDataStack];
	[MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
	[MagicalRecord setErrorHandlerTarget:self action:@selector(_magicalRecordErrorHandler:)];
		
    // Parse
    [Parse setApplicationId:@"Fb00quO11hEkvU1ykKICxMXbhaRL3YO01QR97moM"
                  clientKey:@"80FpNQE39fnd36CHaZrtHNThQdD99Sxk2FUeaD2P"];
    
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|
                                                     UIRemoteNotificationTypeAlert|
                                                     UIRemoteNotificationTypeSound)];


    return YES;
}

#pragma mark - Notifications

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogError(@"Failed to register for remote notifications: %@", error);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

#pragma mark - Private

- (void)_magicalRecordErrorHandler:(NSError *)error {
	DDLogError(@"Core Data error: %@", error);
}

@end
