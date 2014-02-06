// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLSApplication.h instead.

#import <CoreData/CoreData.h>


extern const struct CLSApplicationAttributes {
	__unsafe_unretained NSString *applicationID;
	__unsafe_unretained NSString *bundleID;
	__unsafe_unretained NSString *iconURLString;
	__unsafe_unretained NSString *impactedDevicesCount;
	__unsafe_unretained NSString *latestBuild;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *platform;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *unresolvedIssuesCount;
} CLSApplicationAttributes;

extern const struct CLSApplicationRelationships {
	__unsafe_unretained NSString *builds;
	__unsafe_unretained NSString *filter;
	__unsafe_unretained NSString *issues;
	__unsafe_unretained NSString *organization;
} CLSApplicationRelationships;

extern const struct CLSApplicationFetchedProperties {
} CLSApplicationFetchedProperties;

@class CLSBuild;
@class CLSFilter;
@class CLSIssue;
@class CLSOrganization;











@interface CLSApplicationID : NSManagedObjectID {}
@end

@interface _CLSApplication : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CLSApplicationID*)objectID;





@property (nonatomic, strong) NSString* applicationID;



//- (BOOL)validateApplicationID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* bundleID;



//- (BOOL)validateBundleID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iconURLString;



//- (BOOL)validateIconURLString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* impactedDevicesCount;



@property int32_t impactedDevicesCountValue;
- (int32_t)impactedDevicesCountValue;
- (void)setImpactedDevicesCountValue:(int32_t)value_;

//- (BOOL)validateImpactedDevicesCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* latestBuild;



//- (BOOL)validateLatestBuild:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* platform;



//- (BOOL)validatePlatform:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* status;



//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* unresolvedIssuesCount;



@property int32_t unresolvedIssuesCountValue;
- (int32_t)unresolvedIssuesCountValue;
- (void)setUnresolvedIssuesCountValue:(int32_t)value_;

//- (BOOL)validateUnresolvedIssuesCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *builds;

- (NSMutableSet*)buildsSet;




@property (nonatomic, strong) CLSFilter *filter;

//- (BOOL)validateFilter:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *issues;

- (NSMutableSet*)issuesSet;




@property (nonatomic, strong) CLSOrganization *organization;

//- (BOOL)validateOrganization:(id*)value_ error:(NSError**)error_;





@end

@interface _CLSApplication (CoreDataGeneratedAccessors)

- (void)addBuilds:(NSSet*)value_;
- (void)removeBuilds:(NSSet*)value_;
- (void)addBuildsObject:(CLSBuild*)value_;
- (void)removeBuildsObject:(CLSBuild*)value_;

- (void)addIssues:(NSSet*)value_;
- (void)removeIssues:(NSSet*)value_;
- (void)addIssuesObject:(CLSIssue*)value_;
- (void)removeIssuesObject:(CLSIssue*)value_;

@end

@interface _CLSApplication (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveApplicationID;
- (void)setPrimitiveApplicationID:(NSString*)value;




- (NSString*)primitiveBundleID;
- (void)setPrimitiveBundleID:(NSString*)value;




- (NSString*)primitiveIconURLString;
- (void)setPrimitiveIconURLString:(NSString*)value;




- (NSNumber*)primitiveImpactedDevicesCount;
- (void)setPrimitiveImpactedDevicesCount:(NSNumber*)value;

- (int32_t)primitiveImpactedDevicesCountValue;
- (void)setPrimitiveImpactedDevicesCountValue:(int32_t)value_;




- (NSString*)primitiveLatestBuild;
- (void)setPrimitiveLatestBuild:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitivePlatform;
- (void)setPrimitivePlatform:(NSString*)value;




- (NSString*)primitiveStatus;
- (void)setPrimitiveStatus:(NSString*)value;




- (NSNumber*)primitiveUnresolvedIssuesCount;
- (void)setPrimitiveUnresolvedIssuesCount:(NSNumber*)value;

- (int32_t)primitiveUnresolvedIssuesCountValue;
- (void)setPrimitiveUnresolvedIssuesCountValue:(int32_t)value_;





- (NSMutableSet*)primitiveBuilds;
- (void)setPrimitiveBuilds:(NSMutableSet*)value;



- (CLSFilter*)primitiveFilter;
- (void)setPrimitiveFilter:(CLSFilter*)value;



- (NSMutableSet*)primitiveIssues;
- (void)setPrimitiveIssues:(NSMutableSet*)value;



- (CLSOrganization*)primitiveOrganization;
- (void)setPrimitiveOrganization:(CLSOrganization*)value;


@end
