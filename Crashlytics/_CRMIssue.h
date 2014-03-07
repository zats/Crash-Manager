// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLSIssue.h instead.

#import <CoreData/CoreData.h>


extern const struct CLSIssueAttributes {
	__unsafe_unretained NSString *crashesCount;
	__unsafe_unretained NSString *devicesAffected;
	__unsafe_unretained NSString *displayID;
	__unsafe_unretained NSString *impactLevel;
	__unsafe_unretained NSString *issueID;
	__unsafe_unretained NSString *lastSession;
	__unsafe_unretained NSString *lastSessionData;
	__unsafe_unretained NSString *latestIncidentID;
	__unsafe_unretained NSString *resolvedAt;
	__unsafe_unretained NSString *subtitle;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *urlString;
} CLSIssueAttributes;

extern const struct CLSIssueRelationships {
	__unsafe_unretained NSString *application;
	__unsafe_unretained NSString *build;
} CLSIssueRelationships;

extern const struct CLSIssueFetchedProperties {
} CLSIssueFetchedProperties;

@class CRMApplication;
@class CRMBuild;






@class NSObject;







@interface CLSIssueID : NSManagedObjectID {}
@end

@interface _CRMIssue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CLSIssueID*)objectID;





@property (nonatomic, strong) NSNumber* crashesCount;



@property int32_t crashesCountValue;
- (int32_t)crashesCountValue;
- (void)setCrashesCountValue:(int32_t)value_;

//- (BOOL)validateCrashesCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* devicesAffected;



@property int32_t devicesAffectedValue;
- (int32_t)devicesAffectedValue;
- (void)setDevicesAffectedValue:(int32_t)value_;

//- (BOOL)validateDevicesAffected:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* displayID;



@property int32_t displayIDValue;
- (int32_t)displayIDValue;
- (void)setDisplayIDValue:(int32_t)value_;

//- (BOOL)validateDisplayID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* impactLevel;



@property int32_t impactLevelValue;
- (int32_t)impactLevelValue;
- (void)setImpactLevelValue:(int32_t)value_;

//- (BOOL)validateImpactLevel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* issueID;



//- (BOOL)validateIssueID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id lastSession;



//- (BOOL)validateLastSession:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* lastSessionData;



//- (BOOL)validateLastSessionData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* latestIncidentID;



//- (BOOL)validateLatestIncidentID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* resolvedAt;



//- (BOOL)validateResolvedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* subtitle;



//- (BOOL)validateSubtitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* urlString;



//- (BOOL)validateUrlString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CRMApplication *application;

//- (BOOL)validateApplication:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) CRMBuild *build;

//- (BOOL)validateBuild:(id*)value_ error:(NSError**)error_;





@end

@interface _CRMIssue (CoreDataGeneratedAccessors)

@end

@interface _CRMIssue (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCrashesCount;
- (void)setPrimitiveCrashesCount:(NSNumber*)value;

- (int32_t)primitiveCrashesCountValue;
- (void)setPrimitiveCrashesCountValue:(int32_t)value_;




- (NSNumber*)primitiveDevicesAffected;
- (void)setPrimitiveDevicesAffected:(NSNumber*)value;

- (int32_t)primitiveDevicesAffectedValue;
- (void)setPrimitiveDevicesAffectedValue:(int32_t)value_;




- (NSNumber*)primitiveDisplayID;
- (void)setPrimitiveDisplayID:(NSNumber*)value;

- (int32_t)primitiveDisplayIDValue;
- (void)setPrimitiveDisplayIDValue:(int32_t)value_;




- (NSNumber*)primitiveImpactLevel;
- (void)setPrimitiveImpactLevel:(NSNumber*)value;

- (int32_t)primitiveImpactLevelValue;
- (void)setPrimitiveImpactLevelValue:(int32_t)value_;




- (NSString*)primitiveIssueID;
- (void)setPrimitiveIssueID:(NSString*)value;




- (id)primitiveLastSession;
- (void)setPrimitiveLastSession:(id)value;




- (NSData*)primitiveLastSessionData;
- (void)setPrimitiveLastSessionData:(NSData*)value;




- (NSString*)primitiveLatestIncidentID;
- (void)setPrimitiveLatestIncidentID:(NSString*)value;




- (NSDate*)primitiveResolvedAt;
- (void)setPrimitiveResolvedAt:(NSDate*)value;




- (NSString*)primitiveSubtitle;
- (void)setPrimitiveSubtitle:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveUrlString;
- (void)setPrimitiveUrlString:(NSString*)value;





- (CRMApplication*)primitiveApplication;
- (void)setPrimitiveApplication:(CRMApplication*)value;



- (CRMBuild*)primitiveBuild;
- (void)setPrimitiveBuild:(CRMBuild*)value;


@end
