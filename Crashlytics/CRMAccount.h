#import "_CRMAccount.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>

extern NSString *const CLSActiveAccountDidChangeNotification;

@class RACSubject;
@interface CRMAccount : _CRMAccount {}

@end

@interface CRMAccount (CLSSession)

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;
- (void)updateOrganizationsWithContentsOfArray:(NSArray *)organizationsArray;

- (BOOL)canCreateSession;
- (BOOL)canRestoreSession;

@end

@interface CRMAccount (CLSCurrentAccount)

+ (RACSubject *)activeAccountChangedSignal;

+ (instancetype)activeAccount;
+ (instancetype)currentAccountInContext:(NSManagedObjectContext *)context;
+ (void)setCurrentAccount:(CRMAccount *)account;

@end

@interface CRMAccount (CLSUtility)

+ (void)getKeychainedLastUsedUsername:(NSString **)username
							 password:(NSString **)password;

@end
