// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRMAccount.m instead.

#import "_CRMAccount.h"

const struct CRMAccountAttributes CRMAccountAttributes = {
	.email = @"email",
	.name = @"name",
	.password = @"password",
	.token = @"token",
	.userID = @"userID",
};

const struct CRMAccountRelationships CRMAccountRelationships = {
	.organizations = @"organizations",
};

const struct CRMAccountFetchedProperties CRMAccountFetchedProperties = {
};

@implementation CRMAccountID
@end

@implementation _CRMAccount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Account";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Account" inManagedObjectContext:moc_];
}

- (CRMAccountID *)objectID {
	return (CRMAccountID *)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic email;






@dynamic name;






@dynamic password;






@dynamic token;






@dynamic userID;






@dynamic organizations;

	
- (NSMutableSet*)organizationsSet {
	[self willAccessValueForKey:@"organizations"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"organizations"];
  
	[self didAccessValueForKey:@"organizations"];
	return result;
}
	






@end
