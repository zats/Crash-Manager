// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRMFilter.h instead.

#import <CoreData/CoreData.h>


extern const struct CRMFilterAttributes {
	__unsafe_unretained NSString *issueNewerThen;
	__unsafe_unretained NSString *issueOlderThen;
	__unsafe_unretained NSString *issueStatus;
} CRMFilterAttributes;

extern const struct CRMFilterRelationships {
	__unsafe_unretained NSString *application;
	__unsafe_unretained NSString *build;
} CRMFilterRelationships;

extern const struct CRMFilterFetchedProperties {
} CRMFilterFetchedProperties;

@class CRMApplication;
@class CRMBuild;





@interface CRMFilterID : NSManagedObjectID {}
@end

@interface _CRMFilter : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CRMFilterID *)objectID;





@property (nonatomic, strong) NSNumber* issueNewerThen;



@property int32_t issueNewerThenValue;
- (int32_t)issueNewerThenValue;
- (void)setIssueNewerThenValue:(int32_t)value_;

//- (BOOL)validateIssueNewerThen:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* issueOlderThen;



@property int32_t issueOlderThenValue;
- (int32_t)issueOlderThenValue;
- (void)setIssueOlderThenValue:(int32_t)value_;

//- (BOOL)validateIssueOlderThen:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* issueStatus;



//- (BOOL)validateIssueStatus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CRMApplication *application;

//- (BOOL)validateApplication:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) CRMBuild *build;

//- (BOOL)validateBuild:(id*)value_ error:(NSError**)error_;





@end

@interface _CRMFilter (CoreDataGeneratedAccessors)

@end

@interface _CRMFilter (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIssueNewerThen;
- (void)setPrimitiveIssueNewerThen:(NSNumber*)value;

- (int32_t)primitiveIssueNewerThenValue;
- (void)setPrimitiveIssueNewerThenValue:(int32_t)value_;




- (NSNumber*)primitiveIssueOlderThen;
- (void)setPrimitiveIssueOlderThen:(NSNumber*)value;

- (int32_t)primitiveIssueOlderThenValue;
- (void)setPrimitiveIssueOlderThenValue:(int32_t)value_;




- (NSString*)primitiveIssueStatus;
- (void)setPrimitiveIssueStatus:(NSString*)value;





- (CRMApplication*)primitiveApplication;
- (void)setPrimitiveApplication:(CRMApplication*)value;



- (CRMBuild*)primitiveBuild;
- (void)setPrimitiveBuild:(CRMBuild*)value;


@end
