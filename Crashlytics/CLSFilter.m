#import "CLSFilter.h"

#import "CLSBuild.h"
#import "CLSIssue.h"
#import "CLSApplication.h"

NSString *const CLSFilterIssueStatusAll = @"all";
NSString *const CLSFilterIssueStatusUnresolved = @"unresolved";
NSString *const CLSFilterIssueStatusResolved = @"resolved";

NSString *const CLSFilterLabelKey = @"CLSIssueStatusFilterLabelKey";
NSString *const CLSFilterValueKey = @"CLSIssueStatusFilterValueKey";

id CLSFilterTimeRangeAll;
NSArray *CLSFilterTimeRangeLastHour;
NSArray *CLSFilterTimeRangeLast24Hours;
NSArray *CLSFilterTimeRangeLast48Hours;
NSArray *CLSFilterTimeRangeLast7Days;
NSArray *CLSFilterTimeRangeLast30Days;


NSArray *CLSFilterIssueStatuses;
NSArray *CLSFilterTimeRanges;

#define CLSStrignify( key ) (@#key)

@interface CLSFilter ()

@end


@implementation CLSFilter

+ (void)initialize {
	@autoreleasepool {
		
		// Issue Statuses
		CLSFilterIssueStatuses = @[
		  @{ CLSFilterLabelKey : CLSLocalizedDisplayStringForFiterIssueStatus(CLSFilterIssueStatusAll),
			 CLSFilterValueKey : CLSFilterIssueStatusAll },
		  @{ CLSFilterLabelKey : CLSLocalizedDisplayStringForFiterIssueStatus(CLSFilterIssueStatusResolved),
			 CLSFilterValueKey : CLSFilterIssueStatusResolved },
		  @{ CLSFilterLabelKey : CLSLocalizedDisplayStringForFiterIssueStatus(CLSFilterIssueStatusUnresolved),
			 CLSFilterValueKey : CLSFilterIssueStatusUnresolved },
		];
		
		// Time Ranges
		
		CLSFilterTimeRangeAll = @[ @0, @0 ];
		CLSFilterTimeRangeLastHour = @[ @0, @-3600 ];
		CLSFilterTimeRangeLast24Hours = @[ @0, @-86400 ];
		CLSFilterTimeRangeLast48Hours = @[ @0, @-172800 ];
		CLSFilterTimeRangeLast7Days = @[ @0, @-604800 ];
		CLSFilterTimeRangeLast30Days  = @[ @0, @-2592000 ];
		
		CLSFilterTimeRanges = @[
			@{ CLSFilterLabelKey : NSLocalizedString(CLSStrignify(CLSFilterTimeRangeAll), @"All time range for issues filter"),
			   CLSFilterValueKey : CLSFilterTimeRangeAll },
			@{ CLSFilterLabelKey : NSLocalizedString(CLSStrignify(CLSFilterTimeRangeLastHour), @"Last hour range for issues filter"),
			   CLSFilterValueKey : CLSFilterTimeRangeLastHour },
			@{ CLSFilterLabelKey : NSLocalizedString(CLSStrignify(CLSFilterTimeRangeLast24Hours), @"Last day range for issues filter"),
			   CLSFilterValueKey : CLSFilterTimeRangeLast24Hours },
			@{ CLSFilterLabelKey : NSLocalizedString(CLSStrignify(CLSFilterTimeRangeLast48Hours), @"Last two days range for issues filter"),
			   CLSFilterValueKey : CLSFilterTimeRangeLast48Hours },
			@{ CLSFilterLabelKey : NSLocalizedString(CLSStrignify(CLSFilterTimeRangeLast7Days), @"Last week range for issues filter"),
			   CLSFilterValueKey : CLSFilterTimeRangeLast7Days },
			@{ CLSFilterLabelKey : NSLocalizedString(CLSStrignify(CLSFilterTimeRangeLast30Days), @"Last month range for issues filter"),
			   CLSFilterValueKey : CLSFilterTimeRangeLast30Days }
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

- (BOOL)isTimeRangeFilterSet {
	return !([self.issueOlderThen isEqualToNumber:CLSFilterTimeRangeAll[0]] &&
			 [self.issueNewerThen isEqualToNumber:CLSFilterTimeRangeAll[1]]);
}

- (BOOL)isBuildFilterSet {
	return self.build != nil;
}

- (BOOL)isStatusFilterSet {
	return ![self.issueStatus isEqualToString:CLSFilterIssueStatusAll];
}

- (BOOL)isFilterSet {
	return ([self isBuildFilterSet] ||
			[self isStatusFilterSet] ||
			[self isTimeRangeFilterSet]);
}

- (void)resetFilter {
	self.build = nil;
	self.issueStatus = CLSFilterIssueStatusAll;
	[self setIssueTimeRangeArray:CLSFilterTimeRangeAll];
}

- (NSString *)summaryString {
	if (![self isFilterSet]) {
		return nil;
	}
	NSString *result = [NSString string];
	if (self.build)  {
		result = [result stringByAppendingFormat:@"%@  ", self.build.buildID];
	}
	NSArray *timeRangeArray = [self issueTimeRangeArray];
	if (![CLSFilterTimeRangeAll isEqualToArray:timeRangeArray])  {
		result = [result stringByAppendingFormat:@"%@  ", CLSLocalizedDisplayStringForFilterTimeRange(timeRangeArray)];
	}
	if (![CLSFilterIssueStatusAll isEqualToString:self.issueStatus]) {
		result = [result stringByAppendingFormat:@"%@  ", CLSLocalizedDisplayStringForFiterIssueStatus(self.issueStatus)];
	}
	if ([result length]) {
		result = [result substringToIndex:[result length] - 2];
	}
	return [result length] ? result : nil;
}

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
	[super awakeFromInsert];
	
	self.issueStatus = CLSFilterIssueStatusAll;

	self.issueOlderThen = CLSFilterTimeRangeAll[0];
	self.issueNewerThen = CLSFilterTimeRangeAll[1];
}

#undef CLSStrignify

@end

@implementation CLSFilter (CLSPredicate)

- (NSPredicate *)emptyFilterPreidacte {
	return [NSPredicate predicateWithFormat:@"%K == %@", CLSIssueRelationships.application, self.application];
}

- (NSPredicate *)predicate {
	NSMutableArray *predicates = [NSMutableArray arrayWithObject:[self emptyFilterPreidacte]];
	if ([self isStatusFilterSet]) {
		if ([self.issueStatus isEqualToString:CLSFilterIssueStatusResolved]) {
			[predicates addObject:[NSPredicate predicateWithFormat:@"%K != nil", CLSIssueAttributes.resolvedAt]];
		} else if ([self.issueStatus isEqualToString:CLSFilterIssueStatusUnresolved]) {
			[predicates addObject:[NSPredicate predicateWithFormat:@"%K == nil", CLSIssueAttributes.resolvedAt]];
		}
	}
	if ([self isBuildFilterSet]) {
		[predicates addObject:[NSPredicate predicateWithFormat:@"%K == %@", CLSIssueRelationships.build, self.build]];
	}
	if ([self isTimeRangeFilterSet]) {
		// No predicate can match time range
	}
	if ([predicates count] == 1) {
		return [predicates firstObject];
	}
	return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

@end
