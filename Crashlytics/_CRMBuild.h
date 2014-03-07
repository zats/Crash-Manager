// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLSBuild.h instead.

#import <CoreData/CoreData.h>


extern const struct CLSBuildAttributes {
	__unsafe_unretained NSString *buildID;
	__unsafe_unretained NSString *collectCrashReports;
} CLSBuildAttributes;

extern const struct CLSBuildRelationships {
	__unsafe_unretained NSString *application;
	__unsafe_unretained NSString *filters;
	__unsafe_unretained NSString *issues;
} CLSBuildRelationships;

extern const struct CLSBuildFetchedProperties {
} CLSBuildFetchedProperties;

@class CRMApplication;
@class CRMFilter;
@class CRMIssue;




@interface CLSBuildID : NSManagedObjectID {}
@end

@interface _CRMBuild : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CLSBuildID*)objectID;





@property (nonatomic, strong) NSString* buildID;



//- (BOOL)validateBuildID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* collectCrashReports;



@property BOOL collectCrashReportsValue;
- (BOOL)collectCrashReportsValue;
- (void)setCollectCrashReportsValue:(BOOL)value_;

//- (BOOL)validateCollectCrashReports:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CRMApplication *application;

//- (BOOL)validateApplication:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) CRMFilter *filters;

//- (BOOL)validateFilters:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *issues;

- (NSMutableSet*)issuesSet;





@end

@interface _CRMBuild (CoreDataGeneratedAccessors)

- (void)addIssues:(NSSet*)value_;
- (void)removeIssues:(NSSet*)value_;
- (void)addIssuesObject:(CRMIssue*)value_;
- (void)removeIssuesObject:(CRMIssue*)value_;

@end

@interface _CRMBuild (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBuildID;
- (void)setPrimitiveBuildID:(NSString*)value;




- (NSNumber*)primitiveCollectCrashReports;
- (void)setPrimitiveCollectCrashReports:(NSNumber*)value;

- (BOOL)primitiveCollectCrashReportsValue;
- (void)setPrimitiveCollectCrashReportsValue:(BOOL)value_;





- (CRMApplication*)primitiveApplication;
- (void)setPrimitiveApplication:(CRMApplication*)value;



- (CRMFilter *)primitiveFilters;
- (void)setPrimitiveFilters:(CRMFilter *)value;



- (NSMutableSet*)primitiveIssues;
- (void)setPrimitiveIssues:(NSMutableSet*)value;


@end
