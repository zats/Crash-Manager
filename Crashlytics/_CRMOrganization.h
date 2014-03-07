// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLSOrganization.h instead.

#import <CoreData/CoreData.h>


extern const struct CLSOrganizationAttributes {
	__unsafe_unretained NSString *accountsCount;
	__unsafe_unretained NSString *alias;
	__unsafe_unretained NSString *apiKey;
	__unsafe_unretained NSString *appsCount;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *organizationID;
} CLSOrganizationAttributes;

extern const struct CLSOrganizationRelationships {
	__unsafe_unretained NSString *accounts;
	__unsafe_unretained NSString *applications;
} CLSOrganizationRelationships;

extern const struct CLSOrganizationFetchedProperties {
} CLSOrganizationFetchedProperties;

@class CRMAccount;
@class CRMApplication;








@interface CLSOrganizationID : NSManagedObjectID {}
@end

@interface _CRMOrganization : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CLSOrganizationID*)objectID;





@property (nonatomic, strong) NSNumber* accountsCount;



@property int32_t accountsCountValue;
- (int32_t)accountsCountValue;
- (void)setAccountsCountValue:(int32_t)value_;

//- (BOOL)validateAccountsCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* alias;



//- (BOOL)validateAlias:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* apiKey;



//- (BOOL)validateApiKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* appsCount;



@property int32_t appsCountValue;
- (int32_t)appsCountValue;
- (void)setAppsCountValue:(int32_t)value_;

//- (BOOL)validateAppsCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* organizationID;



//- (BOOL)validateOrganizationID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *accounts;

- (NSMutableSet*)accountsSet;




@property (nonatomic, strong) NSSet *applications;

- (NSMutableSet*)applicationsSet;





@end

@interface _CRMOrganization (CoreDataGeneratedAccessors)

- (void)addAccounts:(NSSet*)value_;
- (void)removeAccounts:(NSSet*)value_;
- (void)addAccountsObject:(CRMAccount*)value_;
- (void)removeAccountsObject:(CRMAccount*)value_;

- (void)addApplications:(NSSet*)value_;
- (void)removeApplications:(NSSet*)value_;
- (void)addApplicationsObject:(CRMApplication*)value_;
- (void)removeApplicationsObject:(CRMApplication*)value_;

@end

@interface _CRMOrganization (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAccountsCount;
- (void)setPrimitiveAccountsCount:(NSNumber*)value;

- (int32_t)primitiveAccountsCountValue;
- (void)setPrimitiveAccountsCountValue:(int32_t)value_;




- (NSString*)primitiveAlias;
- (void)setPrimitiveAlias:(NSString*)value;




- (NSString*)primitiveApiKey;
- (void)setPrimitiveApiKey:(NSString*)value;




- (NSNumber*)primitiveAppsCount;
- (void)setPrimitiveAppsCount:(NSNumber*)value;

- (int32_t)primitiveAppsCountValue;
- (void)setPrimitiveAppsCountValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveOrganizationID;
- (void)setPrimitiveOrganizationID:(NSString*)value;





- (NSMutableSet*)primitiveAccounts;
- (void)setPrimitiveAccounts:(NSMutableSet*)value;



- (NSMutableSet*)primitiveApplications;
- (void)setPrimitiveApplications:(NSMutableSet*)value;


@end
