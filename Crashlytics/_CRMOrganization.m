// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRMOrganization.m instead.

#import "_CRMOrganization.h"

const struct CRMOrganizationAttributes CRMOrganizationAttributes = {
	.accountsCount = @"accountsCount",
	.alias = @"alias",
	.apiKey = @"apiKey",
	.appsCount = @"appsCount",
	.name = @"name",
	.organizationID = @"organizationID",
};

const struct CRMOrganizationRelationships CRMOrganizationRelationships = {
	.accounts = @"accounts",
	.applications = @"applications",
};

const struct CRMOrganizationFetchedProperties CRMOrganizationFetchedProperties = {
};

@implementation CRMOrganizationID
@end

@implementation _CRMOrganization

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Organization" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Organization";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Organization" inManagedObjectContext:moc_];
}

- (CRMOrganizationID *)objectID {
	return (CRMOrganizationID *)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"accountsCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"accountsCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"appsCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"appsCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic accountsCount;



- (int32_t)accountsCountValue {
	NSNumber *result = [self accountsCount];
	return [result intValue];
}

- (void)setAccountsCountValue:(int32_t)value_ {
	[self setAccountsCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveAccountsCountValue {
	NSNumber *result = [self primitiveAccountsCount];
	return [result intValue];
}

- (void)setPrimitiveAccountsCountValue:(int32_t)value_ {
	[self setPrimitiveAccountsCount:[NSNumber numberWithInt:value_]];
}





@dynamic alias;






@dynamic apiKey;






@dynamic appsCount;



- (int32_t)appsCountValue {
	NSNumber *result = [self appsCount];
	return [result intValue];
}

- (void)setAppsCountValue:(int32_t)value_ {
	[self setAppsCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveAppsCountValue {
	NSNumber *result = [self primitiveAppsCount];
	return [result intValue];
}

- (void)setPrimitiveAppsCountValue:(int32_t)value_ {
	[self setPrimitiveAppsCount:[NSNumber numberWithInt:value_]];
}





@dynamic name;






@dynamic organizationID;






@dynamic accounts;

	
- (NSMutableSet*)accountsSet {
	[self willAccessValueForKey:@"accounts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"accounts"];
  
	[self didAccessValueForKey:@"accounts"];
	return result;
}
	

@dynamic applications;

	
- (NSMutableSet*)applicationsSet {
	[self willAccessValueForKey:@"applications"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"applications"];
  
	[self didAccessValueForKey:@"applications"];
	return result;
}
	






@end
