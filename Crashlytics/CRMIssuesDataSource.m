//
//  CRMIssuesDataSource.m
//  CrashManager
//
//  Created by Sasha Zats on 3/8/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMIssuesDataSource.h"

#import "CRMBuild.h"
#import "CRMIssue.h"
#import "CRMIssueListCell.h"
#import <TTTLocalizedPluralString/TTTLocalizedPluralString.h>

@interface CRMIssuesDataSource ()
@property (nonatomic, weak, readwrite) UITableView *tableView;
@end

@implementation CRMIssuesDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.tableView = tableView;
    
    return self;
}

#pragma mark - UITableViewDataSource 

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end

@implementation CRMIssuesDataSource (SubclassingHooks)

- (CRMIssue *)issueForIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSIndexPath *)indexPathForIssue:(CRMIssue *)issue {
    return nil;
}

- (void)configureCell:(CRMIssueListCell *)cell withIssue:(CRMIssue *)issue indexPath:(NSIndexPath *)indexPath {
	cell.issueNumberLabel.text = [issue.displayID description];
	cell.issueTitleLabel.textColor = [issue isResolved] ? [UIColor lightGrayColor] : [UIColor blackColor];
	cell.issueTitleLabel.text = issue.title;
	cell.issueSubtitleLabel.text = issue.subtitle;
	cell.impactLevelImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"issue-impact-level-%@", issue.impactLevel]];
	
	NSString *crashesString = TTTLocalizedPluralString(issue.crashesCountValue, @"CRMIssueListCrashesCount", @"Crashes count for issues list screen");
	NSString *usersAffected = TTTLocalizedPluralString(issue.devicesAffectedValue, @"CRMIssueListUsersAffected", @"Users affected count for issues list screen");
	cell.issueDetailsLabel.text = [NSString stringWithFormat:@"%@  %@  %@", issue.build.buildID, crashesString,  usersAffected];
	// adjusting layout for the cell according to its position in the table view
	if ([self isOnlyRowAtIndexPath:indexPath]) {
		cell.baseLayoutConstraint.constant = -2;
	} else if ([self isLastRowAtIndexPath:indexPath]) {
		cell.baseLayoutConstraint.constant = 1;
	} else if ([self isFirstRowAtIndexPath:indexPath]) {
		cell.baseLayoutConstraint.constant = -5;
	} else {
		// any intermidiate row
		cell.baseLayoutConstraint.constant = -2;
	}
}

- (BOOL)isOnlyRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)isFirstRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)isLastRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
