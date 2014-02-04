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
#import <Appsee/Appsee.h>

@interface CLSAppDelegate () <CrashlyticsDelegate>
@end

@implementation CLSAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [CLSConfiguration sharedInstance];
    
    // TODO: Stick with one: AppSee or GoogleAnalytics

    // AppSee
    [Appsee start:@"e6f5703eda674ec59beb9ab49b712d4a"];
    
    // Google Analytics
	id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-46469219-2"];
	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [tracker set:kGAIAppVersion value:version];
	[GAI sharedInstance].logger.logLevel = kGAILogLevelInfo;

    // Configuration
	[[CLSConfiguration sharedInstance] updateConfigurationPlistWithCompletionHandler:^(NSDictionary *defaults, NSError *error) {
		NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"CrashlyticsAPIKey"];
		[Crashlytics startWithAPIKey:apiKey];
		
		if (error) {
			[[GAI sharedInstance].logger error:[NSString stringWithFormat:@"Failed to fetch remote plist: %@", error]];
		}
	}];
	
    // Core Data stack
	[MagicalRecord setupAutoMigratingCoreDataStack];
	
    return YES;
}

@end
