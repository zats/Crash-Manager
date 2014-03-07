//
//  CLSIncident_Session+Crashlytics.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/26/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMIncident_Session+Crashlytics.h"

@implementation CRMSession (Crashlytics)

- (CGFloat)deviceAvailableRamPercentage {
	return (1.0 - (CGFloat)[self lastEvent].device.ramUsed / self.device.ram) * 100.0;
}

- (CGFloat)deviceAvailableDiskSpacePercentage {
	return (1.0 - (CGFloat)[self lastEvent].device.diskUsed / self.device.diskSpace) * 100.0;
}

- (CRMSessionEvent *)lastEvent {
	return [self.events count] ? [self eventsAtIndex:[self.events count]-1] : nil;
}

- (BOOL)containsException {
	CRMSessionException *exception = [self lastEvent].app.execution.exception;
	return [exception hasType] && [exception hasReason];
}

- (CRMSessionException *)lastException {
	return [self lastEvent].app.execution.exception;
}

- (CRMSessionBinaryImage *)binaryImageForAddress:(uint64_t)address {
	for (CRMSessionBinaryImage *binaryImage in [self lastEvent].app.execution.binaries) {
		if (binaryImage.baseAddress <= address && binaryImage.baseAddress + binaryImage.size > address) {
			return binaryImage;
		}
	}
	return nil;
}

- (CRMSessionThread *)crashedThread {
	CRMSessionEvent *event = [self lastEvent];
	uint64_t address = event.app.execution.signal.address;
	for (CRMSessionThread *thread in event.app.execution.threads) {
 		for (CRMSessionFrame *frame in thread.frames) {
			if (frame.pc == address) {
				return thread;
			}
		}
	}
	return nil;
	
}

@end

@implementation CRMSessionSignal (Crashlytics)

- (NSString *)displayString {	
	return [NSString stringWithFormat:@"%@ %@ at 0x%x", self.name, self.code, self.address];
}

@end

@implementation CRMSessionDevice (Crashlytics)

- (NSString *)displayString {
	if (!([self.manufacturer length] ||
		  [self.model length] ||
		  [self.modelClass length])) {
		return nil;
	}
	NSString *string = [NSString string];
	if ([self.manufacturer length]) {
		string = [string stringByAppendingFormat:@"%@ ", self.manufacturer];
	}
	
	if ([self.model length]) {
		string = [string stringByAppendingFormat:@"%@ ", [self _modelForIdentifier:self.model]];
	}

	if ([self.modelClass length]) {
		string = [string stringByAppendingFormat:@"%@ ", self.modelClass];
	}
	
	return [string substringToIndex:[string length] - 1];
}

- (NSString *)_modelForIdentifier:(NSString *)rawModel {
	static NSArray *deviceModelsMapping;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSArray *rawDeviceModels = [[NSUserDefaults standardUserDefaults] objectForKey:@"CrashlyticsDeviceModels"];
		deviceModelsMapping = [[rawDeviceModels.rac_sequence map:^id(NSDictionary *value) {
			NSMutableDictionary *result = [value mutableCopy];
			NSString *prefix = result[@"prefix"];
			NSArray *suffixes = result[@"suffixes"];
			suffixes = [[suffixes.rac_sequence map:^id(NSDictionary *suffixPair) {
				NSMutableDictionary *result = [suffixPair mutableCopy];
				// prepends regex with a model prefix
				// iPhone1(_|,){1}}\d
				NSString *rawRegex = [prefix stringByAppendingString:suffixPair[@"regex"]];
				//				rawRegex = [NSRegularExpression escapedTemplateForString:rawRegex];
				NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:rawRegex
																					   options:0
																						 error:0];
				if (!regex) {
					
					[result removeObjectForKey:@"regex"];
				} else {
					result[@"regex"] = regex;
				}
				return [result copy];
			}] array];
			result[@"suffixes"] = suffixes;
			return [result copy];
		}] array];
	});
	
	NSString *result = rawModel;
	NSRange modelRange = NSMakeRange(0, [rawModel length]);
	for (NSDictionary *deviceData in deviceModelsMapping) {
		if ([rawModel hasPrefix:deviceData[@"prefix"]]) {
			NSString *deviceName = deviceData[@"name"];
			for (NSDictionary *deviceModel in deviceData[@"suffixes"]) {
				NSRegularExpression *regex = deviceModel[@"regex"];
				if ([regex numberOfMatchesInString:rawModel
										   options:0
											 range:modelRange]) {
					NSString *deviceModelName = deviceModel[@"name"];
					// Original iPhone or iPad doesn't have a model name
					if (![deviceModelName length]) {
						return deviceName;
					}
					return [NSString stringWithFormat:@"%@ %@", deviceName, deviceModelName];
				}
			}
		}
	}
	
	return result;
}

@end

@implementation CRMSessionEventDevice (Crashlytics)

- (NSString *)batteryDisplayString {
	if (self.batteryVelocity == 3) {
		return @"Full";
	}
	
	if (self.batteryLevel >= 0 && self.batteryLevel <= 1.0) {
		if (self.batteryVelocity == 2) {
			return [NSString stringWithFormat:@"%.0f%% charging", self.batteryLevel * 100];
		}
		return [NSString stringWithFormat:@"%.0f%%", self.batteryLevel * 100];
	}
	return nil;
}

- (NSString *)orientationDisplayString {
	switch (self.orientation) {
		case 1:
		case 2:
			return @"Portrait";
		case 3:
		case 4:
			return @"Landscape";
		case 5:
			return @"Face down";
		case 6:
			return @"Face up";
		default:
			return nil;
	}
}

@end

@implementation CRMSessionUser (Crashlytics)

- (NSString *)displayString {
	static NSString *kNullString;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		kNullString = [NSString stringWithFormat:@"%@", nil];
	});
	
	NSString *_email = self.email;
	if ([_email isEqualToString:kNullString]) {
		_email = nil;
	}
	NSString *_name = self.name;
	if ([_name isEqualToString:kNullString]) {
		_name = nil;
	}
	
	if (!([_email length] ||
		  [_name length])) {
		return nil;
	}
	
	NSString *result = [NSString string];
	if ([_name length]) {
		result = [result stringByAppendingFormat:@"%@ ", _name];
	}
	if ([_email length]) {
		result = [result stringByAppendingString:_email];
	}
	return result;
}

@end

@implementation CRMSessionOperatingSystem (Crashlytics)

- (NSString *)displayString {
	NSString *result = [NSString string];
	switch (self.platform) {
		case CLSIncident_PlatformAndroid:
			result = [result stringByAppendingString:@"Android"];
			break;

		case CLSIncident_PlatformIphoneOs:
			result = [result stringByAppendingString:@"iOS"];
			break;
			
		case CLSIncident_PlatformMacOsX:
			result = [result stringByAppendingString:@"Mac OS"];

		default:
			break;
	}
	if ([self.version length]) {
		if ([result length]) {
			result = [result stringByAppendingString:@" "];
		}
		result = [result stringByAppendingString:self.version];
	}
	
	if ([self.buildVersion length]) {
		if ([result length]) {
			result = [result stringByAppendingString:@" "];
		}
		result = [result stringByAppendingFormat:@"(%@)", self.buildVersion];
	}
	
	return result;
}

@end
