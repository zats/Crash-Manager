#import "_CLSApplication.h"

@interface CLSApplication : _CLSApplication {}

+ (instancetype)applicationWithContentsOfDictionary:(NSDictionary *)dictionary
										  inContext:(NSManagedObjectContext *)context;

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;

- (void)updateBuildsWithContentsOfArray:(NSArray *)array;

/**
 Updates according builds with issues from the array
 
 @param array Array of serialized issues to parse
 */
- (void)updateIssuesWithContentsOfArray:(NSArray *)array;

@end
