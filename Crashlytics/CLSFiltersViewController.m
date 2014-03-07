//
//  CLSFiltersViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/30/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSFiltersViewController.h"

#import "CRMApplication.h"
#import "CRMFilter.h"
#import "CRMBuild.h"
#import "CLSIssueStatusFilterViewController.h"
#import "CLSBuildsFilterViewController.h"
#import "CLSTimeRangeFilterViewController.h"
#import <ReactiveCocoa/RACEXTScope.h>

typedef NS_ENUM(NSInteger, CLSFilterTableViewCell) {
	kCLSFilterTableViewCellBuild = 0,
	kCLSFilterTableViewCellIssueStatus = 1,
	kCLSFilterTableViewCellTimeRange = 2
};

@interface CLSFiltersViewController ()

@property (nonatomic, strong) NSString *applicationID;
@property (nonatomic, weak, readonly) CRMFilter *filter;

@end

@implementation CLSFiltersViewController

#pragma mark - Public

- (void)setApplication:(CRMApplication *)application {
	self.applicationID = application.applicationID;
	
	@weakify(self);
	[RACObserve(self.filter, issueStatus) subscribeNext:^(NSString *issueStatus) {
		@strongify(self);
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kCLSFilterTableViewCellIssueStatus
																						 inSection:0]];
		cell.detailTextLabel.text = CLSLocalizedDisplayStringForFiterIssueStatus(issueStatus);
	}];
	
	[[RACSignal combineLatest:@[ RACObserve(self.filter, issueNewerThen), RACObserve(self.filter, issueOlderThen) ]] subscribeNext:^(id x) {
		@strongify(self);
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kCLSFilterTableViewCellTimeRange
																						 inSection:0]];
		cell.detailTextLabel.text = CLSLocalizedDisplayStringForFilterTimeRange([self.filter issueTimeRangeArray]);
	}];

	[RACObserve(self.filter, build) subscribeNext:^(id x) {
		@strongify(self);
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kCLSFilterTableViewCellBuild
																						 inSection:0]];
		
		cell.detailTextLabel.text = self.filter.build ? self.filter.build.buildID : @"All Builds";
	}];
}

- (CRMApplication *)application {
	return [CRMApplication MR_findFirstByAttribute:CLSApplicationAttributes.applicationID
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
		CLSIssueStatusFilterViewController *issueStatusFilterViewController = segue.destinationViewController;
		issueStatusFilterViewController.filter = self.filter;
	} else if ([segue.identifier isEqualToString:@"filter-build"]) {
		CLSBuildsFilterViewController *buildsFilterViewController = segue.destinationViewController;
		buildsFilterViewController.filter = self.filter;
	} else if ([segue.identifier isEqualToString:@"filter-timeRange"]) {
		CLSTimeRangeFilterViewController *timeRangeFilterViewController = segue.destinationViewController;
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
	if (indexPath.row == kCLSFilterTableViewCellBuild) {
		cell.detailTextLabel.text = self.filter.build ? self.filter.build.buildID : @"All Builds";
	} else if (indexPath.row == kCLSFilterTableViewCellIssueStatus) {
		cell.detailTextLabel.text = CLSLocalizedDisplayStringForFiterIssueStatus(self.filter.issueStatus);
	} else if (indexPath.row == kCLSFilterTableViewCellTimeRange) {
		cell.detailTextLabel.text = CLSLocalizedDisplayStringForFilterTimeRange([self.filter issueTimeRangeArray]);
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
