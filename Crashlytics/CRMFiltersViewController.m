//
//  CRMFiltersViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/30/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMFiltersViewController.h"

#import "CRMApplication.h"
#import "CRMFilter.h"
#import "CRMBuild.h"
#import "CRMIssueStatusFilterViewController.h"
#import "CRMBuildsFilterViewController.h"
#import "CRMTimeRangeFilterViewController.h"
#import <ReactiveCocoa/RACEXTScope.h>

typedef NS_ENUM(NSInteger, CRMFilterTableViewCell) {
	kCRMFilterTableViewCellBuild = 0,
	kCRMFilterTableViewCellIssueStatus = 1,
	kCRMFilterTableViewCellTimeRange = 2
};

@interface CRMFiltersViewController ()

@property (nonatomic, strong) NSString *applicationID;
@property (nonatomic, weak, readonly) CRMFilter *filter;

@end

@implementation CRMFiltersViewController

#pragma mark - Public

- (void)setApplication:(CRMApplication *)application {
	self.applicationID = application.applicationID;
	
	@weakify(self);
	[RACObserve(self.filter, issueStatus) subscribeNext:^(NSString *issueStatus) {
		@strongify(self);
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kCRMFilterTableViewCellIssueStatus
																						 inSection:0]];
		cell.detailTextLabel.text = CRMLocalizedDisplayStringForFiterIssueStatus(issueStatus);
	}];
	
	[[RACSignal combineLatest:@[ RACObserve(self.filter, issueNewerThen), RACObserve(self.filter, issueOlderThen) ]] subscribeNext:^(id x) {
		@strongify(self);
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kCRMFilterTableViewCellTimeRange
																						 inSection:0]];
		cell.detailTextLabel.text = CRMLocalizedDisplayStringForFilterTimeRange([self.filter issueTimeRangeArray]);
	}];

	[RACObserve(self.filter, build) subscribeNext:^(id x) {
		@strongify(self);
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kCRMFilterTableViewCellBuild
																						 inSection:0]];
		
		cell.detailTextLabel.text = self.filter.build ? self.filter.build.buildID : @"All Builds";
	}];
}

- (CRMApplication *)application {
	return [CRMApplication MR_findFirstByAttribute:CRMApplicationAttributes.applicationID
										 withValue:self.applicationID];
}

- (CRMFilter *)filter {
	CRMApplication *applicaiton = self.application;
	if (!applicaiton.filter) {
		applicaiton.filter = [CRMFilter MR_createInContext:applicaiton.managedObjectContext];
		[applicaiton.filter.managedObjectContext MR_saveToPersistentStoreAndWait];
	}
	return applicaiton.filter;
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"filter-issueStatus"]) {
		CRMIssueStatusFilterViewController *issueStatusFilterViewController = segue.destinationViewController;
		issueStatusFilterViewController.filter = self.filter;
	} else if ([segue.identifier isEqualToString:@"filter-build"]) {
		CRMBuildsFilterViewController *buildsFilterViewController = segue.destinationViewController;
		buildsFilterViewController.filter = self.filter;
	} else if ([segue.identifier isEqualToString:@"filter-timeRange"]) {
		CRMTimeRangeFilterViewController *timeRangeFilterViewController = segue.destinationViewController;
		timeRangeFilterViewController.filter = self.filter;
	}
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView
					   cellForRowAtIndexPath:indexPath];
	// Reset filters cell
	if (indexPath.section != 0) {
		return cell;
	}

	// Filters
	if (indexPath.row == kCRMFilterTableViewCellBuild) {
		cell.detailTextLabel.text = self.filter.build ? self.filter.build.buildID : @"All Builds";
	} else if (indexPath.row == kCRMFilterTableViewCellIssueStatus) {
		cell.detailTextLabel.text = CRMLocalizedDisplayStringForFiterIssueStatus(self.filter.issueStatus);
	} else if (indexPath.row == kCRMFilterTableViewCellTimeRange) {
		cell.detailTextLabel.text = CRMLocalizedDisplayStringForFilterTimeRange([self.filter issueTimeRangeArray]);
	}
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && indexPath.row == 0) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.filter resetFilter];
		[self.filter.managedObjectContext MR_saveToPersistentStoreAndWait];
	}
}

@end
