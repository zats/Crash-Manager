#import "_CLSOrganization.h"

@interface CLSOrganization : _CLSOrganization {}

+ (instancetype)organizationWithContentsOfDictionary:(NSDictionary *)dictionary
										   inContext:(NSManagedObjectContext *)context;

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;

- (void)updateApplicationsWithContentsOfArray:(NSArray *)array;

@end
