//
//  CLSAppDelegate.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSAppDelegate.h"

#import "CLSConfiguration.h"
#import <Crashlytics/Crashlytics.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface CLSAppDelegate () <CrashlyticsDelegate>
@end

@implementation CLSAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Configuration
	[[CLSConfiguration sharedInstance] updateConfigurationPlistWithCompletionHandler:^(NSDictionary *defaults, NSError *error) {
		NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"CrashlyticsAPIKey"];
		[Crashlytics startWithAPIKey:apiKey];
		
		if (error) {
			[[GAI sharedInstance].logger error:[NSString stringWithFormat:@"Failed to fetch remote plist: %@", error]];
		}
	}];
	
	// Google Analytics
	id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-46469219-2"];
	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [tracker set:kGAIAppVersion value:version];
	[GAI sharedInstance].logger.logLevel = kGAILogLevelInfo;
	
    // Core Data stack
	[MagicalRecord setupAutoMigratingCoreDataStack];
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[UIApplication sharedApplication].keyWindow.tintColor = [UIColor colorWithRed:0.769 green:0.031 blue:0.075 alpha:1.000];

// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
