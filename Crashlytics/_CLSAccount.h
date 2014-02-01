// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLSAccount.h instead.

#import <CoreData/CoreData.h>


extern const struct CLSAccountAttributes {
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *password;
	__unsafe_unretained NSString *token;
	__unsafe_unretained NSString *userID;
} CLSAccountAttributes;

extern const struct CLSAccountRelationships {
	__unsafe_unretained NSString *organizations;
} CLSAccountRelationships;

extern const struct CLSAccountFetchedProperties {
} CLSAccountFetchedProperties;

@class CLSOrganization;







@interface CLSAccountID : NSManagedObjectID {}
@end

@interface _CLSAccount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CLSAccountID*)objectID;





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

@interface _CLSAccount (CoreDataGeneratedAccessors)

- (void)addOrganizations:(NSSet*)value_;
- (void)removeOrganizations:(NSSet*)value_;
- (void)addOrganizationsObject:(CLSOrganization*)value_;
- (void)removeOrganizationsObject:(CLSOrganization*)value_;

@end

@interface _CLSAccount (CoreDataGeneratedPrimitiveAccessors)


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
