#import "_CLSBuild.h"

@interface CLSBuild : _CLSBuild {}

+ (instancetype)buildWithContentsOfDictionary:(NSDictionary *)dictionary
									inContext:(NSManagedObjectContext *)context;

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;

@end
