//
//  CRMIncident_Session+Crashlytics.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/26/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMIncident.h"

@interface CRMSession (Crashlytics)

- (CRMSessionEvent *)lastEvent;

- (CRMSessionBinaryImage *)binaryImageForAddress:(uint64_t)address;

- (BOOL)containsException;

/**
 Returns the Thread that contains frame that led to the crash.
 
 @return A thread with containing crashed frame or `nil` if it can not be found.
 */
- (CRMSessionThread *)crashedThread;

- (CGFloat)deviceAvailableRamPercentage;

- (CGFloat)deviceAvailableDiskSpacePercentage;

- (CRMSessionException *)lastException;

@end

@interface CRMSessionSignal (Crashlytics)

- (NSString *)displayString;

@end

@interface CRMSessionUser (Crashlytics)

- (NSString *)displayString;

@end

@interface CRMSessionDevice (Crashlytics)

- (NSString *)displayString;

@end

@interface CRMSessionEventDevice (Crashlytics)

- (NSString *)batteryDisplayString;
- (NSString *)orientationDisplayString;

@end

@interface CRMSessionOperatingSystem (Crashlytics)

- (NSString *)displayString;

@end
