// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLSApplication.m instead.

#import "_CLSApplication.h"

const struct CLSApplicationAttributes CLSApplicationAttributes = {
	.applicationID = @"applicationID",
	.bundleID = @"bundleID",
	.iconURLString = @"iconURLString",
	.impactedDevicesCount = @"impactedDevicesCount",
	.latestBuild = @"latestBuild",
	.name = @"name",
	.platform = @"platform",
	.status = @"status",
	.unresolvedIssuesCount = @"unresolvedIssuesCount",
};

const struct CLSApplicationRelationships CLSApplicationRelationships = {
	.builds = @"builds",
	.filter = @"filter",
	.issues = @"issues",
	.organization = @"organization",
};

const struct CLSApplicationFetchedProperties CLSApplicationFetchedProperties = {
};

@implementation CLSApplicationID
@end

@implementation _CLSApplication

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Application" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Application";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Application" inManagedObjectContext:moc_];
}

- (CLSApplicationID*)objectID {
	return (CLSApplicationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"impactedDevicesCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"impactedDevicesCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"unresolvedIssuesCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"unresolvedIssuesCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic applicationID;






@dynamic bundleID;






@dynamic iconURLString;






@dynamic impactedDevicesCount;



- (int32_t)impactedDevicesCountValue {
	NSNumber *result = [self impactedDevicesCount];
	return [result intValue];
}

- (void)setImpactedDevicesCountValue:(int32_t)value_ {
	[self setImpactedDevicesCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveImpactedDevicesCountValue {
	NSNumber *result = [self primitiveImpactedDevicesCount];
	return [result intValue];
}

- (void)setPrimitiveImpactedDevicesCountValue:(int32_t)value_ {
	[self setPrimitiveImpactedDevicesCount:[NSNumber numberWithInt:value_]];
}





@dynamic latestBuild;






@dynamic name;






@dynamic platform;






@dynamic status;






@dynamic unresolvedIssuesCount;



- (int32_t)unresolvedIssuesCountValue {
	NSNumber *result = [self unresolvedIssuesCount];
	return [result intValue];
}

- (void)setUnresolvedIssuesCountValue:(int32_t)value_ {
	[self setUnresolvedIssuesCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveUnresolvedIssuesCountValue {
	NSNumber *result = [self primitiveUnresolvedIssuesCount];
	return [result intValue];
}

- (void)setPrimitiveUnresolvedIssuesCountValue:(int32_t)value_ {
	[self setPrimitiveUnresolvedIssuesCount:[NSNumber numberWithInt:value_]];
}





@dynamic builds;

	
- (NSMutableSet*)buildsSet {
	[self willAccessValueForKey:@"builds"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"builds"];
  
	[self didAccessValueForKey:@"builds"];
	return result;
}
	

@dynamic filter;

	

@dynamic issues;

	
- (NSMutableSet*)issuesSet {
	[self willAccessValueForKey:@"issues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"issues"];
  
	[self didAccessValueForKey:@"issues"];
	return result;
}
	

@dynamic organization;

	






@end
