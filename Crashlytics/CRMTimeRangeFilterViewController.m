//
//  CRMTimeRangeFilterViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/31/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMTimeRangeFilterViewController.h"

#import "CRMFilter.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface CRMTimeRangeFilterViewController ()

@end

@implementation CRMTimeRangeFilterViewController

#pragma mark - Actions

- (IBAction)_filterBarButtonItemHandler:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	@weakify(self);
	[RACObserve(self, filter) subscribeNext:^(CRMFilter *filter) {
		@strongify(self);
		if ([self isViewLoaded]) {
			[self.tableView reloadData];
		}
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return [CRMFilterTimeRanges count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeRangeCellIdentifier"
															forIndexPath:indexPath];
	NSDictionary *timeRangeTuple = CRMFilterTimeRanges[indexPath.row];
	cell.textLabel.text = timeRangeTuple[CRMFilterLabelKey];
	BOOL isSelected = [[self.filter issueTimeRangeArray] isEqualToArray:timeRangeTuple[CRMFilterValueKey]];
	cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *selectedTimeRangeTuple = CRMFilterTimeRanges[indexPath.row];
	[self.filter setIssueTimeRangeArray:selectedTimeRangeTuple[CRMFilterValueKey]];
	[self.filter.managedObjectContext MR_saveToPersistentStoreAndWait];
	for (NSUInteger row = 0; row < [CRMFilterTimeRanges count]; ++row) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row
																					inSection:0]];
		BOOL isSelected = (row == indexPath.row);
		cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	}
}

@end
