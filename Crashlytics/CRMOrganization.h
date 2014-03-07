#import "_CRMOrganization.h"

@interface CRMOrganization : _CRMOrganization {}

+ (instancetype)organizationWithContentsOfDictionary:(NSDictionary *)dictionary
										   inContext:(NSManagedObjectContext *)context;

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;

- (void)updateApplicationsWithContentsOfArray:(NSArray *)array;

@end
