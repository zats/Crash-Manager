//
//  CLSSettings.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSConfiguration.h"

#import "CLSGoogleAnalyticsLogger.h"
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDFileLogger.h>
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

+ (NSString *)builtinConfigurationPlistPath {
    static NSString *builtinPlistPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        builtinPlistPath = [[NSBundle mainBundle] pathForResource:@"configuration"
                                                           ofType:@"plist"];
    });
    return builtinPlistPath;
}

- (instancetype)init {
	self = [super init];
	if (!self) {
		return nil;
	}
    [self _setupLogger];
    [self _setupConfigurationFile];
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

#pragma mark - Private

- (void)_setupLogger {
    [DDTTYLogger sharedInstance].logFormatter = [[DDLogFileFormatterDefault alloc] init];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[CLSGoogleAnalyticsLogger sharedInstance]];
}

- (void)_setupConfigurationFile {
	NSString *destinationPlistPath = [[self class] configurationPlistPath];
	// If plist doesn't exist at target location, copy it from the package
    
    // File does not exist at destination, copy the built in
	if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPlistPath]) {
        DDLogVerbose(@"Configuration file was not found at destination %@, copying from the bundle", destinationPlistPath);
        [self _copyBuiltinPreferencesToPath:destinationPlistPath];
	} else {
        NSError *error = nil;
        // Existent configuration plist
        NSDictionary *destinationAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:destinationPlistPath
                                                                                                      error:&error];
        NSDate *destinationModificationDate = [destinationAttributes fileModificationDate];
        
        // Builtin configuration plist that comes with a bundle
        NSDictionary *builtinAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[[self class] builtinConfigurationPlistPath]
                                                                                                   error:&error];
        NSDate *builtinModificationDate = [builtinAttributes fileModificationDate];
        BOOL builtInFileOlderThanDestination = (builtinAttributes &&
                                                destinationAttributes &&
                                                [builtinModificationDate compare:destinationModificationDate] == NSOrderedAscending);
        if (!builtInFileOlderThanDestination) {
            DDLogVerbose(@"Builtin plist file is newer than the one at %@: builtin creation date %@, destination creation date %@", destinationPlistPath, builtinModificationDate, destinationModificationDate);;
            [self _copyBuiltinPreferencesToPath:destinationPlistPath];
        }
    }
	
    // Finally, merging defaults found at the destination with NSUserDefaults
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:destinationPlistPath];
	[[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:dictionary];
    
}

- (void)_copyBuiltinPreferencesToPath:(NSString *)conigurationPlistPath {
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[conigurationPlistPath stringByDeletingLastPathComponent]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        DDLogWarn(@"Could not create a directory at path %@: %@", [conigurationPlistPath stringByDeletingLastPathComponent], [error localizedDescription]);
    }

    if (![[NSFileManager defaultManager] copyItemAtPath:[[self class] builtinConfigurationPlistPath]
                                                 toPath:conigurationPlistPath
                                                  error:&error]) {
        DDLogError(@"Could not copy plist from %@ to %@: %@", [[self class] builtinConfigurationPlistPath], conigurationPlistPath, [error localizedDescription]);
    }
    
}

@end
