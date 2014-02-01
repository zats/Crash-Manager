#import "_CLSIssue.h"

#import "CLSIncident.h"

@interface CLSIssue : _CLSIssue {}

+ (NSDateFormatter *)formatter;

+ (instancetype)issueWithContentsOfDictionary:(NSDictionary *)dictioanry
									inContext:(NSManagedObjectContext *)context;

- (BOOL)isResolved;

- (NSURL *)URL;

@property (nonatomic, strong) CLSSession *lastSession;

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;

@end
