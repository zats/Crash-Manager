#import "_CRMBuild.h"

@interface CRMBuild : _CRMBuild {}

+ (instancetype)buildWithContentsOfDictionary:(NSDictionary *)dictionary
									inContext:(NSManagedObjectContext *)context;

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;

@end
