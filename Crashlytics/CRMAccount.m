#import "CRMAccount.h"

#import "CRMOrganization.h"
#import <SSKeychain/SSKeychain.h>

static NSString *const CRMCurrentAccountKeyName = @"CRMCurrentAccountKeyName";
static NSString *const CRMKeychainServiceName = @"CRMKeychainServiceName";

NSString *const CRMActiveAccountDidChangeNotification = @"CRMActiveAccountDidChangeNotification";

@interface CRMAccount ()

+ (RACSubject *)activeAccountInternalSignal;

@end


@implementation CRMAccount

+ (RACSubject *)activeAccountInternalSignal {
	static RACSubject *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [RACSubject subject];
	});
	return instance;
}

@end

@implementation CRMAccount (CRMSession)

- (void)updateWithContentsOfDictionary:(NSDictionary *)dictionary {
	self.userID = dictionary[@"id"];
	self.token = dictionary[@"token"];
	self.email = dictionary[@"email"];
	self.name = dictionary[@"name"];	
	if (dictionary[@"organizations"]) {
		NSMutableSet *organizations = [NSMutableSet set];
		for (NSDictionary *organizationDictionary in dictionary[@"organizations"]) {
			CRMOrganization *organization = [CRMOrganization organizationWithContentsOfDictionary:organizationDictionary
																						inContext:self.managedObjectContext];
			if (organization) {
				[organizations addObject:organization];
			}
		}
		self.organizations = organizations;
	}
}

- (void)updateOrganizationsWithContentsOfArray:(NSArray *)organizationsArray {
	NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
	NSMutableSet *organizationsSet = [NSMutableSet setWithCapacity:[organizationsArray count]];
	for (NSDictionary *organizationDictioanry in organizationsArray) {
		CRMOrganization *organization = [CRMOrganization organizationWithContentsOfDictionary:organizationDictioanry
																					inContext:defaultContext];
		if (organization) {
			[organizationsSet addObject:organization];
		}
	}
	self.organizations = [organizationsSet copy];
}

- (BOOL)canCreateSession {
	return [self.email length] && [self.password length];	
}

- (BOOL)canRestoreSession {
	return [self.token length];
}

- (NSString *)password {
    [self willAccessValueForKey:CRMAccountAttributes.password];
    NSString *result = self.primitivePassword;
    [self didAccessValueForKey:CRMAccountAttributes.password];
    if (result) {
        return result;
    }
    
    NSError *error = nil;
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = CRMKeychainServiceName;
    query.account = self.email;
    [query fetch:&error];
    
    if (error) {
        if ([error code] != errSecItemNotFound) {
            DDLogError(@"Failed to fetch password %@", error);
        }
        self.primitivePassword = nil;
    }
    self.primitivePassword = query.password;
    return self.primitivePassword;
}

- (void)willSave {
    NSError *error = nil;
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = CRMKeychainServiceName;
    query.account = self.primitiveEmail;
    query.password = self.primitivePassword;
    if (![query save:&error]) {
        DDLogError(@"Failed to persist password to the keychain %@", error);
    }

    [super willSave];
}

@end

@implementation CRMAccount (CRMCurrentAccount)

+ (RACSignal *)activeAccountChangedSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		[subscriber sendNext:[self activeAccount]];
		[[self activeAccountInternalSignal] subscribe:subscriber];
		return nil;
    }];
}

+ (void)setCurrentAccount:(CRMAccount *)account {
	if (!account) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:CRMCurrentAccountKeyName];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[[[self class] activeAccountInternalSignal] sendNext:nil];
		return;
	}

	NSParameterAssert(![account.objectID isTemporaryID]);

    [[NSUserDefaults standardUserDefaults] setObject:[[account.objectID URIRepresentation] absoluteString]
                                              forKey:CRMCurrentAccountKeyName];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CRMActiveAccountDidChangeNotification
														object:nil];
	
	[[self activeAccountInternalSignal] sendNext:account];
}

+ (instancetype)activeAccount {
	return [self currentAccountInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (instancetype)currentAccountInContext:(NSManagedObjectContext *)context {
	NSString *objectIDURIString = [[NSUserDefaults standardUserDefaults] objectForKey:CRMCurrentAccountKeyName];
	NSURL *objectIDURI = [NSURL URLWithString:objectIDURIString];
	if (!objectIDURI) {
		return nil;
	}
	
	NSManagedObjectID *objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:objectIDURI];
	if (!objectID) {
		return nil;
	}
	
    NSError *error = nil;
	CRMAccount *currentAccount = (CRMAccount *)[context existingObjectWithID:objectID error:&error];
#ifdef DEBUG
    if (error) {
        NSLog(@"%@", error);
    }
#endif
	return currentAccount;
}

@end

@implementation CRMAccount (CRMUtility)

+ (void)getKeychainedLastUsedUsername:(NSString **)username
							 password:(NSString **)password {
	if (!username || !password) {
		return;
	}

	// Retrieving last used keychain account
	NSSortDescriptor *sortByDateDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSSKeychainLastModifiedKey
																		   ascending:NO];
	NSArray *accounts = [[SSKeychain allAccounts] sortedArrayUsingDescriptors:@[ sortByDateDescriptor ]];
	NSDictionary *lastUsedAccount = [accounts firstObject];
	if (username) {
		*username = lastUsedAccount[ kSSKeychainAccountKey ];
	}
	*password = [SSKeychain passwordForService:CRMKeychainServiceName
									   account:*username];
}

@end
