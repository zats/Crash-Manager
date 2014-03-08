// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRMAccount.h instead.

#import <CoreData/CoreData.h>


extern const struct CRMAccountAttributes {
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *password;
	__unsafe_unretained NSString *token;
	__unsafe_unretained NSString *userID;
} CRMAccountAttributes;

extern const struct CRMAccountRelationships {
	__unsafe_unretained NSString *organizations;
} CRMAccountRelationships;

extern const struct CRMAccountFetchedProperties {
} CRMAccountFetchedProperties;

@class CRMOrganization;







@interface CRMAccountID : NSManagedObjectID {}
@end

@interface _CRMAccount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CRMAccountID *)objectID;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* password;



//- (BOOL)validatePassword:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* token;



//- (BOOL)validateToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userID;



//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *organizations;

- (NSMutableSet*)organizationsSet;





@end

@interface _CRMAccount (CoreDataGeneratedAccessors)

- (void)addOrganizations:(NSSet*)value_;
- (void)removeOrganizations:(NSSet*)value_;
- (void)addOrganizationsObject:(CRMOrganization*)value_;
- (void)removeOrganizationsObject:(CRMOrganization*)value_;

@end

@interface _CRMAccount (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitivePassword;
- (void)setPrimitivePassword:(NSString*)value;




- (NSString*)primitiveToken;
- (void)setPrimitiveToken:(NSString*)value;




- (NSString*)primitiveUserID;
- (void)setPrimitiveUserID:(NSString*)value;





- (NSMutableSet*)primitiveOrganizations;
- (void)setPrimitiveOrganizations:(NSMutableSet*)value;


@end
