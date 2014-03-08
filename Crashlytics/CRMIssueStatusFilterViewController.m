//
//  CRMIssueStatusFilterViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/30/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMIssueStatusFilterViewController.h"

#import "CRMFilter.h"


@interface CRMIssueStatusFilterViewController ()
@end

@implementation CRMIssueStatusFilterViewController

- (IBAction)_filterBarButtonItemHandler:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [CRMFilterIssueStatuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IssueStatusCellIdentifier"
															forIndexPath:indexPath];
	NSDictionary *issueStatusTuple = CRMFilterIssueStatuses[indexPath.row];
	cell.textLabel.text = issueStatusTuple[CRMFilterLabelKey];
	BOOL isSelectedIssueStatus = [self.filter.issueStatus isEqualToString:issueStatusTuple[CRMFilterValueKey]];
	cell.accessoryType = isSelectedIssueStatus ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	NSDictionary *selectedIssueStatusTuple = CRMFilterIssueStatuses[ indexPath.row ];
	NSString *selectedIssueStatus = selectedIssueStatusTuple[CRMFilterValueKey];
	if ([self.filter.issueStatus isEqualToString:selectedIssueStatus]) {
		return;
	}
	
	self.filter.issueStatus = selectedIssueStatusTuple[CRMFilterValueKey];
	
	for (NSUInteger row = 0; row < [tableView numberOfRowsInSection:indexPath.section]; ++row) {
		NSDictionary *issueStatusTuple = CRMFilterIssueStatuses[ row ];
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:indexPath.section]];
		BOOL isSelectedIssueStatus = [selectedIssueStatus isEqualToString:issueStatusTuple[CRMFilterValueKey]];
		cell.accessoryType = isSelectedIssueStatus ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
}

@end
