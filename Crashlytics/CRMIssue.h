#import "_CRMIssue.h"

#import "CRMIncident.h"

@interface CRMIssue : _CRMIssue {}

+ (NSDateFormatter *)formatter;

+ (instancetype)issueWithContentsOfDictionary:(NSDictionary *)dictioanry
									inContext:(NSManagedObjectContext *)context;

- (BOOL)isResolved;

- (NSURL *)URL;

@property (nonatomic, strong) CRMSession *lastSession;

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;

@end
