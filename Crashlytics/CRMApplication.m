#import "CRMApplication.h"

#import "CRMBuild.h"
#import "CRMIssue.h"
#import "CRMFilter.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface CRMApplication ()

// Private interface goes here.

@end


@implementation CRMApplication

+ (instancetype)applicationWithContentsOfDictionary:(NSDictionary *)dictionary
										  inContext:(NSManagedObjectContext *)context {
	NSParameterAssert(dictionary);
	NSParameterAssert(context);
	
	NSString *applicationID = dictionary[@"id"];
	if (![applicationID isKindOfClass:[NSString class]]) {
		return nil;
	}
	
	CRMApplication *application = [CRMApplication MR_findFirstByAttribute:CRMApplicationAttributes.applicationID
																withValue:applicationID
																inContext:context];
	if (!application) {
		application = [CRMApplication MR_createInContext:context];
		application.applicationID = applicationID;
	}
	[application updateWithContentsOfDictionary:dictionary];
	return application;
}

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary {
	self.applicationID = dictionary[@"id"];
	self.bundleID = dictionary[@"bundle_identifier"];

	NSNumber *impactedDevicesCount = dictionary[@"impacted_devices_count"];
	if (impactedDevicesCount) {
		self.impactedDevicesCount = impactedDevicesCount;
	}
	NSNumber *unresolvedIssuesCount = dictionary[@"unresolved_issues_count"];
	if (unresolvedIssuesCount) {
		self.unresolvedIssuesCount = unresolvedIssuesCount;
	}
	
	self.name = dictionary[@"name"];
	NSString *platform = dictionary[@"platform"];
	if ([platform isKindOfClass:[NSString class]]) {
		platform = [platform lowercaseString];
		if ([platform isEqualToString:@"ios"]) {
			self.platform = @"iOS";
		} else if ([platform isEqualToString:@"mac"]) {
			self.platform = @"Mac OS";
		} else {
			self.platform = dictionary[@"name"];
		}
	}
	self.status = dictionary[@"status"];
	self.latestBuild = dictionary[@"latest_build"];
	self.iconURLString = dictionary[@"icon_url"];
}

- (void)updateBuildsWithContentsOfArray:(NSArray *)array {
	NSParameterAssert(array);
	NSMutableSet *buildsSet = [NSMutableSet setWithCapacity:[array count]];
	for (NSDictionary *buildDictionary in array) {
		CRMBuild *build = [CRMBuild buildWithContentsOfDictionary:buildDictionary
														inContext:self.managedObjectContext];
		if (build) {
			[buildsSet addObject:build];
		}
	}
	self.builds = [buildsSet copy];
}

- (void)updateIssuesWithContentsOfArray:(NSArray *)array {
	NSParameterAssert(array);
	NSMutableSet *issuesSet = [NSMutableSet setWithCapacity:[array count]];
	for (NSDictionary *issueDictionary in array) {
		// parses an issue from the dictionary and associates it
		// with according build
		CRMIssue *issue = [CRMIssue issueWithContentsOfDictionary:issueDictionary
														inContext:self.managedObjectContext];
		if (issue) {
			[issuesSet addObject:issue];
		}
	}
	[self addIssues:issuesSet];
}

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
	[super awakeFromInsert];

	self.filter = [CRMFilter MR_createInContext:self.managedObjectContext];
}

@end
