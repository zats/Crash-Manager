#import "CRMIssue.h"

#import "CRMBuild.h"

@interface CRMIssue ()

@end

@implementation CRMIssue
@dynamic lastSession;

+ (NSDateFormatter *)formatter {
	static NSDateFormatter *dateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
		dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
	});
	return dateFormatter;
}

+ (instancetype)issueWithContentsOfDictionary:(NSDictionary *)dictionary
									inContext:(NSManagedObjectContext *)context {
	NSParameterAssert(dictionary);
	NSParameterAssert(context);
	
	NSString *issueID = dictionary[@"id"];
	if (!issueID) {
		return nil;
	}
	CRMIssue *issue = [CRMIssue MR_findFirstByAttribute:CRMIssueAttributes.issueID
											  withValue:issueID
											  inContext:context];
	if (!issue) {
		issue = [CRMIssue MR_createInContext:context];
		issue.issueID = issueID;
	}
	
	[issue updateWithContentsOfDictionary:dictionary];
	
	return issue;
}

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary {
	self.issueID = dictionary[@"id"];
	self.displayID = dictionary[@"display_id"];
	self.title = dictionary[@"title"];
	self.subtitle = dictionary[@"subtitle"];
	self.crashesCount = dictionary[@"crashes_count"];
	self.devicesAffected = dictionary[@"impacted_devices_count"];
	self.urlString = dictionary[@"url"];
	self.impactLevel = dictionary[@"impact_level"];
	
	// resolution date
	NSString *dateString = dictionary[@"resolved_at"];
	self.resolvedAt = [dateString isKindOfClass:[NSString class]] ? [[[self class] formatter] dateFromString:dateString] : nil;
	
	// corresponding build object
	NSString *buildID = dictionary[@"build"];
	CRMBuild *build = [CRMBuild MR_findFirstByAttribute:CRMBuildAttributes.buildID
											  withValue:buildID
											  inContext:self.managedObjectContext];
	if (!build) {
		// we have to create a container build object just to encapsulate
		// all the issues
		build = [CRMBuild MR_createInContext:self.managedObjectContext];
		build.buildID = buildID;
	}
	self.build = build;

	if (self.application) {
		build.application = self.application;
	} else {
		self.application = build.application;
	}
		
	// latest incident ID
	NSString *latestIncidentID = dictionary[@"latest_cls_id"];
	if ([latestIncidentID isKindOfClass:[NSString class]]) {
		self.latestIncidentID = latestIncidentID;
	}
}

- (CRMSession *)lastSession {
	[self willAccessValueForKey:CRMIssueAttributes.lastSession];
	CRMSession *lastSession = self.primitiveLastSession;
	[self didAccessValueForKey:CRMIssueAttributes.lastSession];

	if (lastSession) {
		return lastSession;
	}
	
	if (!self.lastSessionData) {
		return nil;
	}
	lastSession = [CRMSession parseFromData:self.lastSessionData];
	self.primitiveLastSession = lastSession;
	return lastSession;
}

- (BOOL)isResolved {
	return self.resolvedAt != nil;
}

- (NSURL *)URL {
	return [NSURL URLWithString:self.urlString];
}

#pragma mark - NSManagedObject

- (void)willSave {
	self.primitiveLastSessionData = ((CRMSession *)self.primitiveLastSession).data;
	[super willSave];
}


@end
