//
//  CLSIncident_Session+Crashlytics.h
//  Crashlytics
//
//  Created by Sasha Zats on 12/26/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSIncident.h"

@interface CLSSession (Crashlytics)

- (CLSSessionEvent *)lastEvent;

- (CLSSessionBinaryImage *)binaryImageForAddress:(uint64_t)address;

- (BOOL)containsException;

/**
 Returns the Thread that contains frame that led to the crash.
 
 @return A thread with containing crashed frame or `nil` if it can not be found.
 */
- (CLSSessionThread *)crashedThread;

- (CGFloat)deviceAvailableRamPercentage;

- (CGFloat)deviceAvailableDiskSpacePercentage;


@end

@interface CLSSessionSignal (Crashlytics)

- (NSString *)displayString;

@end

@interface CLSSessionUser (Crashlytics)

- (NSString *)displayString;

@end

@interface CLSSessionDevice (Crashlytics)

- (NSString *)displayString;

@end

@interface CLSSessionEventDevice (Crashlytics)

- (NSString *)batteryDisplayString;
- (NSString *)orientationDisplayString;

@end

@interface CLSSessionOperatingSystem (Crashlytics)

- (NSString *)displayString;

@end
