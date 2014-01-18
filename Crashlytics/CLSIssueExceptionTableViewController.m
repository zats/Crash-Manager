//
//  CLSIssueExceptionTableViewController.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/25/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSIssueExceptionTableViewController.h"

#import "CLSIncident.h"
#import "CLSIncident_Session+Crashlytics.h"
#import <SHAlertViewBlocks/SHAlertViewBlocks.h>

@interface CLSIssueExceptionTableViewController ()

@end

@implementation CLSIssueExceptionTableViewController
@synthesize session = _session;

- (void)setSession:(CLSSession *)session {
	_session = session;
	if ([self isViewLoaded]) {
		[self.tableView reloadData];
	}
}

#pragma mark - UIViewController

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if (![self.session.events count]) {
		return 0;
	}
	CLSSessionEvent *event = [self.session.events objectAtIndex:0];
	return [event.app.execution.exception.frames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	CLSSessionFrame *frame = [[self.session lastEvent].app.execution.exception.frames objectAtIndex:indexPath.row];
	uint64_t framePosition = frame.pc + frame.offset;
	CLSSessionBinaryImage *correspondingBinaryImage = [self.session binaryImageForAddress:framePosition];
	NSString *binaryName = correspondingBinaryImage.name;
	NSURL *binaryImageURL = [NSURL fileURLWithPath:correspondingBinaryImage.name];
	if (binaryImageURL) {
		binaryName = [binaryImageURL lastPathComponent];
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExceptionCellIdentifier"
															forIndexPath:indexPath];
	BOOL isDeveloperCode = (frame.importance & CLSIncident_FrameImportanceInDeveloperCode) != 0;
	BOOL isCrashedFrame = (frame.importance & CLSIncident_FrameImportanceLikelyLeadToCrash ) != 0;
	UIColor *color = isCrashedFrame ? [UIColor blackColor] : [UIColor lightGrayColor];
	cell.textLabel.font = isDeveloperCode ? [UIFont boldSystemFontOfSize:18] : [UIFont systemFontOfSize:18];
	cell.textLabel.textColor = color;
	cell.textLabel.text = frame.symbol;
	cell.detailTextLabel.text = binaryName;
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	UIAlertView *alert = [UIAlertView SH_alertViewWithTitle:cell.detailTextLabel.text
												withMessage:cell.textLabel.text];
	[alert SH_addButtonWithTitle:@"Copy" withBlock:^(NSInteger theButtonIndex) {		
		[[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"%@ %@", cell.detailTextLabel.text, cell.textLabel.text]];
	}];
	[alert SH_addButtonCancelWithTitle:@"Cancel" withBlock:nil];
	[alert show];
}

@end
