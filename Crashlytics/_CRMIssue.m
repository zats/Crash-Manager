// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLSIssue.m instead.

#import "_CRMIssue.h"

const struct CLSIssueAttributes CLSIssueAttributes = {
	.crashesCount = @"crashesCount",
	.devicesAffected = @"devicesAffected",
	.displayID = @"displayID",
	.impactLevel = @"impactLevel",
	.issueID = @"issueID",
	.lastSession = @"lastSession",
	.lastSessionData = @"lastSessionData",
	.latestIncidentID = @"latestIncidentID",
	.resolvedAt = @"resolvedAt",
	.subtitle = @"subtitle",
	.title = @"title",
	.urlString = @"urlString",
};

const struct CLSIssueRelationships CLSIssueRelationships = {
	.application = @"application",
	.build = @"build",
};

const struct CLSIssueFetchedProperties CLSIssueFetchedProperties = {
};

@implementation CLSIssueID
@end

@implementation _CRMIssue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Issue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Issue" inManagedObjectContext:moc_];
}

- (CLSIssueID*)objectID {
	return (CLSIssueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"crashesCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"crashesCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"devicesAffectedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"devicesAffected"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"displayIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"displayID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"impactLevelValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"impactLevel"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic crashesCount;



- (int32_t)crashesCountValue {
	NSNumber *result = [self crashesCount];
	return [result intValue];
}

- (void)setCrashesCountValue:(int32_t)value_ {
	[self setCrashesCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCrashesCountValue {
	NSNumber *result = [self primitiveCrashesCount];
	return [result intValue];
}

- (void)setPrimitiveCrashesCountValue:(int32_t)value_ {
	[self setPrimitiveCrashesCount:[NSNumber numberWithInt:value_]];
}





@dynamic devicesAffected;



- (int32_t)devicesAffectedValue {
	NSNumber *result = [self devicesAffected];
	return [result intValue];
}

- (void)setDevicesAffectedValue:(int32_t)value_ {
	[self setDevicesAffected:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDevicesAffectedValue {
	NSNumber *result = [self primitiveDevicesAffected];
	return [result intValue];
}

- (void)setPrimitiveDevicesAffectedValue:(int32_t)value_ {
	[self setPrimitiveDevicesAffected:[NSNumber numberWithInt:value_]];
}





@dynamic displayID;



- (int32_t)displayIDValue {
	NSNumber *result = [self displayID];
	return [result intValue];
}

- (void)setDisplayIDValue:(int32_t)value_ {
	[self setDisplayID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDisplayIDValue {
	NSNumber *result = [self primitiveDisplayID];
	return [result intValue];
}

- (void)setPrimitiveDisplayIDValue:(int32_t)value_ {
	[self setPrimitiveDisplayID:[NSNumber numberWithInt:value_]];
}





@dynamic impactLevel;



- (int32_t)impactLevelValue {
	NSNumber *result = [self impactLevel];
	return [result intValue];
}

- (void)setImpactLevelValue:(int32_t)value_ {
	[self setImpactLevel:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveImpactLevelValue {
	NSNumber *result = [self primitiveImpactLevel];
	return [result intValue];
}

- (void)setPrimitiveImpactLevelValue:(int32_t)value_ {
	[self setPrimitiveImpactLevel:[NSNumber numberWithInt:value_]];
}





@dynamic issueID;






@dynamic lastSession;






@dynamic lastSessionData;






@dynamic latestIncidentID;






@dynamic resolvedAt;






@dynamic subtitle;






@dynamic title;






@dynamic urlString;






@dynamic application;

	

@dynamic build;

	






@end
