#import "CLSBuild.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface CLSBuild ()

// Private interface goes here.

@end


@implementation CLSBuild

+ (instancetype)buildWithContentsOfDictionary:(NSDictionary *)dictionary
									inContext:(NSManagedObjectContext *)context {
	NSString *buildID = dictionary[@"id"];
	if (![buildID isKindOfClass:[NSString class]]) {
		return nil;
	}
	
	CLSBuild *build = [CLSBuild MR_findFirstByAttribute:CLSBuildAttributes.buildID
											  withValue:buildID
											  inContext:context];
	if (!build) {
		build = [CLSBuild MR_createInContext:context];
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
