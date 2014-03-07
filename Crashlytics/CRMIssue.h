#import "_CRMIssue.h"

#import "CLSIncident.h"

@interface CRMIssue : _CRMIssue {}

+ (NSDateFormatter *)formatter;

+ (instancetype)issueWithContentsOfDictionary:(NSDictionary *)dictioanry
									inContext:(NSManagedObjectContext *)context;

- (BOOL)isResolved;

- (NSURL *)URL;

@property (nonatomic, strong) CLSSession *lastSession;

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;

@end
