//
//  CLSIssueStatusFilterViewController.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/30/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSIssueStatusFilterViewController.h"

#import "CLSFilter.h"


@interface CLSIssueStatusFilterViewController ()
@end

@implementation CLSIssueStatusFilterViewController

- (IBAction)_filterBarButtonItemHandler:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [CLSFilterIssueStatuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IssueStatusCellIdentifier"
															forIndexPath:indexPath];
	NSDictionary *issueStatusTuple = CLSFilterIssueStatuses[indexPath.row];
	cell.textLabel.text = issueStatusTuple[ CLSFilterLabelKey ];
	BOOL isSelectedIssueStatus = [self.filter.issueStatus isEqualToString:issueStatusTuple[ CLSFilterValueKey ]];
	cell.accessoryType = isSelectedIssueStatus ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	NSDictionary *selectedIssueStatusTuple = CLSFilterIssueStatuses[ indexPath.row ];
	NSString *selectedIssueStatus = selectedIssueStatusTuple[ CLSFilterValueKey ];
	if ([self.filter.issueStatus isEqualToString:selectedIssueStatus]) {
		return;
	}
	
	self.filter.issueStatus = selectedIssueStatusTuple[ CLSFilterValueKey ];
	
	for (NSUInteger row = 0; row < [tableView numberOfRowsInSection:indexPath.section]; ++row) {
		NSDictionary *issueStatusTuple = CLSFilterIssueStatuses[ row ];
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:indexPath.section]];
		BOOL isSelectedIssueStatus = [selectedIssueStatus isEqualToString:issueStatusTuple[ CLSFilterValueKey ]];
		cell.accessoryType = isSelectedIssueStatus ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
}

@end
