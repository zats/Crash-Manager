// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLSFilter.h instead.

#import <CoreData/CoreData.h>


extern const struct CLSFilterAttributes {
	__unsafe_unretained NSString *issueNewerThen;
	__unsafe_unretained NSString *issueOlderThen;
	__unsafe_unretained NSString *issueStatus;
} CLSFilterAttributes;

extern const struct CLSFilterRelationships {
	__unsafe_unretained NSString *application;
	__unsafe_unretained NSString *build;
} CLSFilterRelationships;

extern const struct CLSFilterFetchedProperties {
} CLSFilterFetchedProperties;

@class CLSApplication;
@class CLSBuild;





@interface CLSFilterID : NSManagedObjectID {}
@end

@interface _CLSFilter : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CLSFilterID*)objectID;





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





@property (nonatomic, strong) CLSApplication *application;

//- (BOOL)validateApplication:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) CLSBuild *build;

//- (BOOL)validateBuild:(id*)value_ error:(NSError**)error_;





@end

@interface _CLSFilter (CoreDataGeneratedAccessors)

@end

@interface _CLSFilter (CoreDataGeneratedPrimitiveAccessors)


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





- (CLSApplication*)primitiveApplication;
- (void)setPrimitiveApplication:(CLSApplication*)value;



- (CLSBuild*)primitiveBuild;
- (void)setPrimitiveBuild:(CLSBuild*)value;


@end
