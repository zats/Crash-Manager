#import "_CRMFilter.h"

extern NSString *const CRMFilterLabelKey;
extern NSString *const CRMFilterValueKey;

// Issue Status Values
extern NSString *const CRMFilterIssueStatusAll;
extern NSString *const CRMFilterIssueStatusUnresolved;
extern NSString *const CRMFilterIssueStatusResolved;

// Time Range Values
extern id CRMFilterTimeRangeAll;
extern NSArray *CRMFilterTimeRangeLastHour;
extern NSArray *CRMFilterTimeRangeLast24Hours;
extern NSArray *CRMFilterTimeRangeLast48Hours;
extern NSArray *CRMFilterTimeRangeLast7Days;
extern NSArray *CRMFilterTimeRangeLast30Days;

// Arrays of possible values for each filter
extern NSArray *CRMFilterIssueStatuses;
extern NSArray *CRMFilterTimeRanges;

static inline NSString *CRMLocalizedDisplayStringForFiterIssueStatus(NSString *filterIssueStatus) {
	return NSLocalizedString(([NSString stringWithFormat:@"CRMFilterIssuesStatus%@", [filterIssueStatus capitalizedString]]), nil);
}

static inline NSString *CRMLocalizedDisplayStringForFilterTimeRange(NSArray *timeRange) {
	for (NSDictionary *timeRangeTuple in CRMFilterTimeRanges) {
		if ([timeRangeTuple[CRMFilterValueKey] isEqual:timeRange]) {
			return timeRangeTuple[CRMFilterLabelKey];
		}
	}
	return nil;
}

@interface CRMFilter : _CRMFilter {}

- (NSArray *)issueTimeRangeArray;
- (void)setIssueTimeRangeArray:(NSArray *)array;

- (BOOL)isFilterSet;

- (BOOL)isTimeRangeFilterSet;
- (BOOL)isBuildFilterSet;
- (BOOL)isStatusFilterSet;
- (void)resetFilter;

- (NSString *)summaryString;

@end

@interface CRMFilter (CRMPredicate)

- (NSPredicate *)emptyFilterPreidacte;

- (NSPredicate *)predicate;

@end
