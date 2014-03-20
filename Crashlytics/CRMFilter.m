#import "CRMFilter.h"

#import "CRMBuild.h"
#import "CRMIssue.h"
#import "CRMApplication.h"

NSString *const CRMFilterIssueStatusAll = @"all";
NSString *const CRMFilterIssueStatusUnresolved = @"unresolved";
NSString *const CRMFilterIssueStatusResolved = @"resolved";

NSString *const CRMFilterLabelKey = @"CRMIssueStatusFilterLabelKey";
NSString *const CRMFilterValueKey = @"CRMIssueStatusFilterValueKey";

id CRMFilterTimeRangeAll;
NSArray *CRMFilterTimeRangeLastHour;
NSArray *CRMFilterTimeRangeLast24Hours;
NSArray *CRMFilterTimeRangeLast48Hours;
NSArray *CRMFilterTimeRangeLast7Days;
NSArray *CRMFilterTimeRangeLast30Days;


NSArray *CRMFilterIssueStatuses;
NSArray *CRMFilterTimeRanges;

#define CRMStrignify( key ) (@#key)

@interface CRMFilter ()

@end


@implementation CRMFilter

+ (void)initialize {
	@autoreleasepool {
		
		// Issue Statuses
		CRMFilterIssueStatuses = @[
		  @{CRMFilterLabelKey : CRMLocalizedDisplayStringForFiterIssueStatus(CRMFilterIssueStatusAll),
                  CRMFilterValueKey : CRMFilterIssueStatusAll},
		  @{CRMFilterLabelKey : CRMLocalizedDisplayStringForFiterIssueStatus(CRMFilterIssueStatusResolved),
                  CRMFilterValueKey : CRMFilterIssueStatusResolved},
		  @{CRMFilterLabelKey : CRMLocalizedDisplayStringForFiterIssueStatus(CRMFilterIssueStatusUnresolved),
                  CRMFilterValueKey : CRMFilterIssueStatusUnresolved},
		];
		
		// Time Ranges
		
		CRMFilterTimeRangeAll = @[ @0, @0 ];
		CRMFilterTimeRangeLastHour = @[ @0, @-3600 ];
		CRMFilterTimeRangeLast24Hours = @[ @0, @-86400 ];
		CRMFilterTimeRangeLast48Hours = @[ @0, @-172800 ];
		CRMFilterTimeRangeLast7Days = @[ @0, @-604800 ];
		CRMFilterTimeRangeLast30Days = @[ @0, @-2592000 ];
		
		CRMFilterTimeRanges = @[
			@{CRMFilterLabelKey : NSLocalizedString(CRMStrignify(CRMFilterTimeRangeAll), @"All time range for issues filter"),
                    CRMFilterValueKey : CRMFilterTimeRangeAll},
			@{CRMFilterLabelKey : NSLocalizedString(CRMStrignify(CRMFilterTimeRangeLastHour), @"Last hour range for issues filter"),
                    CRMFilterValueKey : CRMFilterTimeRangeLastHour},
			@{CRMFilterLabelKey : NSLocalizedString(CRMStrignify(CRMFilterTimeRangeLast24Hours), @"Last day range for issues filter"),
                    CRMFilterValueKey : CRMFilterTimeRangeLast24Hours},
			@{CRMFilterLabelKey : NSLocalizedString(CRMStrignify(CRMFilterTimeRangeLast48Hours), @"Last two days range for issues filter"),
                    CRMFilterValueKey : CRMFilterTimeRangeLast48Hours},
			@{CRMFilterLabelKey : NSLocalizedString(CRMStrignify(CRMFilterTimeRangeLast7Days), @"Last week range for issues filter"),
                    CRMFilterValueKey : CRMFilterTimeRangeLast7Days},
			@{CRMFilterLabelKey : NSLocalizedString(CRMStrignify(CRMFilterTimeRangeLast30Days), @"Last month range for issues filter"),
                    CRMFilterValueKey : CRMFilterTimeRangeLast30Days}
		];
	}
}


- (NSArray *)issueTimeRangeArray {
	if (!self.issueNewerThen || !self.issueOlderThen) {
		return nil;
	}
	
	return @[ self.issueOlderThen, self.issueNewerThen ];
}

- (void)setIssueTimeRangeArray:(NSArray *)array {
	if ([array count] == 2) {
		self.issueOlderThen = array[0];
		self.issueNewerThen = array[1];
	}
}

- (BOOL)isTimeRangeFilterEnabled {
	return !([self.issueOlderThen isEqualToNumber:CRMFilterTimeRangeAll[0]] &&
			 [self.issueNewerThen isEqualToNumber:CRMFilterTimeRangeAll[1]]);
}

- (BOOL)isBuildFilterSet {
	return self.build != nil;
}

- (BOOL)isStatusFilterSet {
	return ![self.issueStatus isEqualToString:CRMFilterIssueStatusAll];
}

- (BOOL)isFilterSet {
	return ([self isBuildFilterSet] ||
			[self isStatusFilterSet] ||
			[self isTimeRangeFilterEnabled]);
}

- (void)resetFilter {
	self.build = nil;
	self.issueStatus = CRMFilterIssueStatusAll;
    [self setIssueTimeRangeArray:CRMFilterTimeRangeAll];
}

- (NSString *)displayString {
	if (![self isFilterSet]) {
		return nil;
	}
	NSString *result = [NSString string];
	if (self.build)  {
		result = [result stringByAppendingFormat:@"%@  ", self.build.buildID];
	}
	NSArray *timeRangeArray = [self issueTimeRangeArray];
	if (![CRMFilterTimeRangeAll isEqualToArray:timeRangeArray])  {
		result = [result stringByAppendingFormat:@"%@  ", CRMLocalizedDisplayStringForFilterTimeRange(timeRangeArray)];
	}
	if (![CRMFilterIssueStatusAll isEqualToString:self.issueStatus]) {
		result = [result stringByAppendingFormat:@"%@  ", CRMLocalizedDisplayStringForFiterIssueStatus(self.issueStatus)];
	}
	if ([result length]) {
		result = [result substringToIndex:[result length] - 2];
	}
	return [result length] ? result : nil;
}

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
	[super awakeFromInsert];
	
	self.issueStatus = CRMFilterIssueStatusAll;

	self.issueOlderThen = CRMFilterTimeRangeAll[0];
	self.issueNewerThen = CRMFilterTimeRangeAll[1];
}

#undef CRMStrignify

@end

@implementation CRMFilter (CRMPredicate)

- (NSPredicate *)emptyFilterPreidacte {
	return [NSPredicate predicateWithFormat:@"%K == %@", CRMIssueRelationships.application, self.application];
}

- (NSPredicate *)predicate {
	NSMutableArray *predicates = [NSMutableArray arrayWithObject:[self emptyFilterPreidacte]];
	if ([self isStatusFilterSet]) {
		if ([self.issueStatus isEqualToString:CRMFilterIssueStatusResolved]) {
			[predicates addObject:[NSPredicate predicateWithFormat:@"%K != nil", CRMIssueAttributes.resolvedAt]];
		} else if ([self.issueStatus isEqualToString:CRMFilterIssueStatusUnresolved]) {
			[predicates addObject:[NSPredicate predicateWithFormat:@"%K == nil", CRMIssueAttributes.resolvedAt]];
		}
	}
	if ([self isBuildFilterSet]) {
		[predicates addObject:[NSPredicate predicateWithFormat:@"%K == %@", CRMIssueRelationships.build, self.build]];
	}
	if ([self isTimeRangeFilterEnabled]) {
		// No predicate can match time range
	}
	if ([predicates count] == 1) {
		return [predicates firstObject];
	}
	return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

@end
