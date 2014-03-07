#import "_CRMFilter.h"

extern NSString *const CLSFilterLabelKey;
extern NSString *const CLSFilterValueKey;

// Issue Status Values
extern NSString *const CLSFilterIssueStatusAll;
extern NSString *const CLSFilterIssueStatusUnresolved;
extern NSString *const CLSFilterIssueStatusResolved;

// Time Range Values
extern id CLSFilterTimeRangeAll;
extern NSArray *CLSFilterTimeRangeLastHour;
extern NSArray *CLSFilterTimeRangeLast24Hours;
extern NSArray *CLSFilterTimeRangeLast48Hours;
extern NSArray *CLSFilterTimeRangeLast7Days;
extern NSArray *CLSFilterTimeRangeLast30Days;

// Arrays of possible values for each filter
extern NSArray *CLSFilterIssueStatuses;
extern NSArray *CLSFilterTimeRanges;

static inline NSString *CLSLocalizedDisplayStringForFiterIssueStatus(NSString *filterIssueStatus) {
	return NSLocalizedString(([NSString stringWithFormat:@"CLSFilterIssuesStatus%@", [filterIssueStatus capitalizedString]]), nil);
}

static inline NSString *CLSLocalizedDisplayStringForFilterTimeRange(NSArray *timeRange) {
	for (NSDictionary *timeRangeTuple in CLSFilterTimeRanges) {
		if ([timeRangeTuple[ CLSFilterValueKey ] isEqual:timeRange]) {
			return timeRangeTuple[ CLSFilterLabelKey ];
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

@interface CRMFilter (CLSPredicate)

- (NSPredicate *)emptyFilterPreidacte;

- (NSPredicate *)predicate;

@end
