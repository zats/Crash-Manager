#import "_CLSAccount.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>

extern NSString *const CLSActiveAccountDidChangeNotification;

@class RACSubject;
@interface CLSAccount : _CLSAccount {}

@end

@interface CLSAccount (CLSSession)

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary;
- (void)updateOrganizationsWithContentsOfArray:(NSArray *)organizationsArray;

- (BOOL)canCreateSession;
- (BOOL)canRestoreSession;

@end

@interface CLSAccount (CLSCurrentAccount)

+ (RACSubject *)activeAccountChangedSignal;

+ (instancetype)activeAccount;
+ (instancetype)currentAccountInContext:(NSManagedObjectContext *)context;
+ (void)setCurrentAccount:(CLSAccount *)account;

@end
