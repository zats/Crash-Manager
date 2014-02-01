// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLSBuild.m instead.

#import "_CLSBuild.h"

const struct CLSBuildAttributes CLSBuildAttributes = {
	.buildID = @"buildID",
	.collectCrashReports = @"collectCrashReports",
};

const struct CLSBuildRelationships CLSBuildRelationships = {
	.application = @"application",
	.filters = @"filters",
	.issues = @"issues",
};

const struct CLSBuildFetchedProperties CLSBuildFetchedProperties = {
};

@implementation CLSBuildID
@end

@implementation _CLSBuild

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Build" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Build";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Build" inManagedObjectContext:moc_];
}

- (CLSBuildID*)objectID {
	return (CLSBuildID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"collectCrashReportsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"collectCrashReports"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic buildID;






@dynamic collectCrashReports;



- (BOOL)collectCrashReportsValue {
	NSNumber *result = [self collectCrashReports];
	return [result boolValue];
}

- (void)setCollectCrashReportsValue:(BOOL)value_ {
	[self setCollectCrashReports:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCollectCrashReportsValue {
	NSNumber *result = [self primitiveCollectCrashReports];
	return [result boolValue];
}

- (void)setPrimitiveCollectCrashReportsValue:(BOOL)value_ {
	[self setPrimitiveCollectCrashReports:[NSNumber numberWithBool:value_]];
}





@dynamic application;

	

@dynamic filters;

	

@dynamic issues;

	
- (NSMutableSet*)issuesSet {
	[self willAccessValueForKey:@"issues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"issues"];
  
	[self didAccessValueForKey:@"issues"];
	return result;
}
	






@end
