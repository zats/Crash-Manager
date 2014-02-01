//
//  CLSTimeRangeFilterViewController.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/31/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSTimeRangeFilterViewController.h"

#import "CLSFilter.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface CLSTimeRangeFilterViewController ()

@end

@implementation CLSTimeRangeFilterViewController

#pragma mark - Actions

- (IBAction)_filterBarButtonItemHandler:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	@weakify(self);
	[RACObserve(self, filter) subscribeNext:^(CLSFilter *filter) {
		@strongify(self);
		if ([self isViewLoaded]) {
			[self.tableView reloadData];
		}
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return [CLSFilterTimeRanges count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeRangeCellIdentifier"
															forIndexPath:indexPath];
	NSDictionary *timeRangeTuple = CLSFilterTimeRanges[indexPath.row];
	cell.textLabel.text = timeRangeTuple[ CLSFilterLabelKey ];
	BOOL isSelected = [[self.filter issueTimeRangeArray] isEqualToArray:timeRangeTuple[ CLSFilterValueKey ]];
	cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *selectedTimeRangeTuple = CLSFilterTimeRanges[indexPath.row];
	[self.filter setIssueTimeRangeArray:selectedTimeRangeTuple[ CLSFilterValueKey ]];
	[self.filter.managedObjectContext MR_saveToPersistentStoreAndWait];
	for (NSUInteger row = 0; row < [CLSFilterTimeRanges count]; ++row) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row
																					inSection:0]];
		BOOL isSelected = (row == indexPath.row);
		cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	}
}

@end
