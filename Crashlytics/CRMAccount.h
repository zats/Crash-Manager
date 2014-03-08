#import "_CRMAccount.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>

extern NSString *const CRMActiveAccountDidChangeNotification;

@class RACSubject;
@interface CRMAccount : _CRMAccount {}

@end

@interface CRMAccount (CRMSession)

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;
- (void)updateOrganizationsWithContentsOfArray:(NSArray *)organizationsArray;

- (BOOL)canCreateSession;
- (BOOL)canRestoreSession;

@end

@interface CRMAccount (CRMCurrentAccount)

+ (RACSubject *)activeAccountChangedSignal;

+ (instancetype)activeAccount;
+ (instancetype)currentAccountInContext:(NSManagedObjectContext *)context;
+ (void)setCurrentAccount:(CRMAccount *)account;

@end

@interface CRMAccount (CRMUtility)

+ (void)getKeychainedLastUsedUsername:(NSString **)username
							 password:(NSString **)password;

@end
