//
//  CLSSettings.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSConfiguration.h"

#import "CRMCrashlyticsLogger.h"
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
	return self;
}

#pragma mark - Public

- (void)setup {
	[self _setupLogger];
    [self _setupConfigurationFile];
}

- (void)updateConfigurationPlistWithCompletionHandler:(CLSSettingsUpdateHandler)completion {
	return;
	NSURL *URL = [NSURL URLWithString:@"http://crashlytics-ios.herokuapp.com/configuration.plist"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    @weakify(self);
    [[NSUserDefaults standardUserDefaults] registerDefaultsWithURLRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *defaults) {
        @strongify(self);
        NSString *lastModifiedDate = [response allHeaderFields][@"Last-Modified"];
        if (!lastModifiedDate) {
            // no last modification date was found in the response
            DDLogWarn(@"Could not find the remote modification date for the configuration file, overriding the local one anyway");
            [self _serializeConfigurationDictionary:defaults
                                         completion:completion];
            return;
        }
        
        // Parsing the last modification date according to
        // http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1
        static NSDateFormatter *dateFormatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        });
        NSDate *remoteModificationDate = [dateFormatter dateFromString:lastModifiedDate];
        if (!remoteModificationDate) {
            DDLogWarn(@"Could not parse the remote modification date for the configuration file, overriding the local one anyway");
            // Couldn't parse date from the headers
            [self _serializeConfigurationDictionary:defaults
                                         completion:completion];
            return;
        }
        
        // now we can finally comapre the date we received from the server with
        // the local destination file
        NSString *destinationPlistPath = [[self class] configurationPlistPath];
        NSError *error = nil;
        NSDictionary *destinationAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:destinationPlistPath
                                                                                               error:&error];
        if (!destinationAttributes) {
            DDLogWarn(@"Couldn't read the file attributes for file at %@", destinationPlistPath);
            [self _serializeConfigurationDictionary:defaults
                                         completion:completion];
            return;
        }
        NSDate *destinationModificationDate = [destinationAttributes fileModificationDate];
        BOOL isLocalFileNewer = (destinationModificationDate &&
                                 [destinationModificationDate compare:remoteModificationDate] == NSOrderedDescending);
        if (isLocalFileNewer) {
            DDLogVerbose(@"Local configuration file is newer than the remote one, keeping the local one");
            completion([[NSUserDefaults standardUserDefaults] dictionaryRepresentation], nil);
            return;
        }
        
        [self _serializeConfigurationDictionary:defaults
                                     completion:completion];
        
        // Setting the last modification attribute from the response
        // FIXME: this actually happen after completion handler was called
        NSMutableDictionary *destinationAttributesM = [destinationAttributes mutableCopy];
        destinationAttributesM[ NSFileModificationDate ] = remoteModificationDate;
        [[NSFileManager defaultManager] setAttributes:destinationAttributesM
                                         ofItemAtPath:destinationPlistPath
                                                error:&error];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        DDLogError(@"Failed to load remote configuration file: %@", [error localizedDescription]);
		completion(nil, error);
    }];
}

- (NSURL *)signUpURL {
	return [NSURL URLWithString: [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CrashlyticsLinks.SignUp"]];
}

- (NSURL *)forgotPasswordURL {
	return [NSURL URLWithString: [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CrashlyticsLinks.ForgotPassword"]];
}

#pragma mark - Private

- (void)_serializeConfigurationDictionary:(NSDictionary *)defaults
                               completion:(CLSSettingsUpdateHandler)completion {
    // Serializing response back to plist
    // TODO: Find a non-hacky way to access response's NSData and just save that
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:defaults
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options:0
                                                               error:&error];
    if (!data) {
        DDLogError(@"Failed to serialize response back to plist: %@", error);
        completion(nil, error);
        return;
    }
    // Write a file to the location
    if (![data writeToFile:[[self class] configurationPlistPath]
                   options:NSDataWritingAtomic
                     error:&error]) {
        DDLogError(@"Failed to save remote configuration file: %@", error);
        completion(nil, error);
        return;
    }
    completion(defaults, nil);
}

- (void)_setupLogger {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
	[DDLog addLogger:[CRMCrashlyticsLogger sharedInstance]];
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
        NSDictionary *destinationAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:destinationPlistPath
                                                                                               error:&error];
        NSDate *destinationModificationDate = [destinationAttributes fileModificationDate];
        
        // Builtin configuration plist that comes with a bundle
        NSDictionary *builtinAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self class] builtinConfigurationPlistPath]
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

- (void)_copyBuiltinPreferencesToPath:(NSString *)destinationPath {
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[destinationPath stringByDeletingLastPathComponent]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        DDLogWarn(@"Could not create a directory at path %@: %@", [destinationPath stringByDeletingLastPathComponent], [error localizedDescription]);
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:destinationPath
                                                        error:&error]) {
            DDLogError(@"Failed to remove existent configuration file at %@", destinationPath);
            return;
        }
    }
    
    if (![[NSFileManager defaultManager] copyItemAtPath:[[self class] builtinConfigurationPlistPath]
                                                 toPath:destinationPath
                                                  error:&error]) {
        DDLogError(@"Could not copy plist from %@ to %@: %@", [[self class] builtinConfigurationPlistPath], destinationPath, [error localizedDescription]);
    }
    
}

@end

@implementation CLSConfiguration (CLSOpenSource)

#pragma mark - Public

- (NSURL *)implementationURLForClass:(Class)className {
    NSString *URLString = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CrashManagerSource.Implementation"];
    return [self _URLForTemplateURLString:URLString class:className];
}

- (NSURL *)interfaceURLForClass:(Class)className {
    NSString *URLString = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CrashManagerSource.Interface"];
    return [self _URLForTemplateURLString:URLString class:className];
}

- (NSURL *)gitHubPageURL {
    NSString *URLString = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CrashManagerSource.GitHub"];
	return [NSURL URLWithString:URLString];
}

#pragma mark - Private

- (NSURL *)_URLForTemplateURLString:(NSString *)URLString class:(Class)className {
    if (!URLString) {
        return nil;
    }
	
    URLString = [URLString stringByReplacingOccurrencesOfString:@"#{class}"
                                                     withString:NSStringFromClass(className)];
	
    // We can cache the build version.
    static NSString *appBuildVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *gitSHA = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GitSHA"];
        if ([gitSHA length]) {
            appBuildVersion = gitSHA;
        } else {
            // it's a stable build, use full semantic version
            appBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleVersionKey];
        }
    });
    NSString *version = [NSString stringWithFormat:@"v%@", appBuildVersion];
    
    URLString = [URLString stringByReplacingOccurrencesOfString:@"#{version}"
                                                     withString:version];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    return URL;
}

@end

@implementation CLSConfiguration (CLSMarketing)

- (NSURL *)marketingURL {
	NSString *URLString = [[NSUserDefaults standardUserDefaults] valueForKey:@"MarketingLink"];
	return [NSURL URLWithString:URLString];
}

- (NSString *)appDisplayName {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

@end
