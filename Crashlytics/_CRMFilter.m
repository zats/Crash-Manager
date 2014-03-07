// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRMFilter.m instead.

#import "_CRMFilter.h"

const struct CLSFilterAttributes CLSFilterAttributes = {
	.issueNewerThen = @"issueNewerThen",
	.issueOlderThen = @"issueOlderThen",
	.issueStatus = @"issueStatus",
};

const struct CLSFilterRelationships CLSFilterRelationships = {
	.application = @"application",
	.build = @"build",
};

const struct CLSFilterFetchedProperties CLSFilterFetchedProperties = {
};

@implementation CLSFilterID
@end

@implementation _CRMFilter

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Filter" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Filter";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Filter" inManagedObjectContext:moc_];
}

- (CLSFilterID*)objectID {
	return (CLSFilterID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"issueNewerThenValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"issueNewerThen"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"issueOlderThenValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"issueOlderThen"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic issueNewerThen;



- (int32_t)issueNewerThenValue {
	NSNumber *result = [self issueNewerThen];
	return [result intValue];
}

- (void)setIssueNewerThenValue:(int32_t)value_ {
	[self setIssueNewerThen:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveIssueNewerThenValue {
	NSNumber *result = [self primitiveIssueNewerThen];
	return [result intValue];
}

- (void)setPrimitiveIssueNewerThenValue:(int32_t)value_ {
	[self setPrimitiveIssueNewerThen:[NSNumber numberWithInt:value_]];
}





@dynamic issueOlderThen;



- (int32_t)issueOlderThenValue {
	NSNumber *result = [self issueOlderThen];
	return [result intValue];
}

- (void)setIssueOlderThenValue:(int32_t)value_ {
	[self setIssueOlderThen:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveIssueOlderThenValue {
	NSNumber *result = [self primitiveIssueOlderThen];
	return [result intValue];
}

- (void)setPrimitiveIssueOlderThenValue:(int32_t)value_ {
	[self setPrimitiveIssueOlderThen:[NSNumber numberWithInt:value_]];
}





@dynamic issueStatus;






@dynamic application;

	

@dynamic build;

	






@end
