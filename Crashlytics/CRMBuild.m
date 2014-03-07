#import "CRMBuild.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface CRMBuild ()

// Private interface goes here.

@end


@implementation CRMBuild

+ (instancetype)buildWithContentsOfDictionary:(NSDictionary *)dictionary
									inContext:(NSManagedObjectContext *)context {
	NSString *buildID = dictionary[@"id"];
	if (![buildID isKindOfClass:[NSString class]]) {
		return nil;
	}
	
	CRMBuild *build = [CRMBuild MR_findFirstByAttribute:CLSBuildAttributes.buildID
											  withValue:buildID
											  inContext:context];
	if (!build) {
		build = [CRMBuild MR_createInContext:context];
		build.buildID = buildID;
	}
	[build updateWithContentsOfDictionary:dictionary];
	return build;
}

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary {
	self.buildID = dictionary[@"id"];
	self.collectCrashReports = dictionary[@"collect_crash_reports"];
}

@end
