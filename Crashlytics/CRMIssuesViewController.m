//
//  CRMIssuesViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/22/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMIssuesViewController.h"

#import "CRMAPIClient.h"
#import "CRMAccount.h"
#import "CRMFilter.h"
#import "CRMApplication.h"
#import "CRMBuild.h"
#import "CRMFiltersViewController.h"
#import "CRMIssue.h"
#import "CRMIssueDetailsViewController.h"
#import "CRMIssueListCell.h"
#import <TTTLocalizedPluralString/TTTLocalizedPluralString.h>

@interface CRMIssuesViewController ()
@property (nonatomic, strong) NSString *applicationID;
@property (nonatomic, strong) NSPredicate *basicPredicate;
@property (nonatomic, strong) RACDisposable *fetchIssuesDisposable;
@property (nonatomic, strong) NSArray *issueIDs;
@end

@implementation CRMIssuesViewController

#pragma mark - Public

- (void)setApplication:(CRMApplication *)application {
	self.applicationID = application.applicationID;
}

- (CRMApplication *)application {
	return [CRMApplication MR_findFirstByAttribute:CRMApplicationAttributes.applicationID
										 withValue:self.applicationID];
}

#pragma mark - Actions

- (IBAction)_refreshControlHandler:(id)sender {
	[self _beginLoading];
}

- (IBAction)_unwindFiltersViewController:(UIStoryboardSegue *)segue {
	NSPredicate *newPredicate = [self.application.filter predicate];
	BOOL hasPredicateChanged = ![self.fetchedResultsController.fetchRequest.predicate isEqual:newPredicate];
	if (!hasPredicateChanged) {
		return;
	}
	self.fetchedResultsController.fetchRequest.predicate = newPredicate;
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		DDLogError(@"Failed to fetch with predicate: %@ for filter %@\n%@", newPredicate,self.application.filter, error);
	}
	[self.tableView reloadData];
	[self _beginLoading];
}

#pragma mark - Private

- (void)_configureCell:(CRMIssueListCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	CRMIssue *issue = [self _issueForIndexPath:indexPath];
	cell.issueNumberLabel.text = [issue.displayID description];
	cell.issueTitleLabel.textColor = [issue isResolved] ? [UIColor lightGrayColor] : [UIColor blackColor];
	cell.issueTitleLabel.text = issue.title;
	cell.issueSubtitleLabel.text = issue.subtitle;
	cell.impactLevelImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"issue-impact-level-%@", issue.impactLevel]];
	
	NSString *crashesString = TTTLocalizedPluralString(issue.crashesCountValue, @"CRMIssueListCrashesCount", @"Crashes count for issues list screen");
	NSString *usersAffected = TTTLocalizedPluralString(issue.devicesAffectedValue, @"CRMIssueListUsersAffected", @"Users affected count for issues list screen");
	cell.issueDetailsLabel.text = [NSString stringWithFormat:@"%@  %@  %@", issue.build.buildID, crashesString,  usersAffected];
	// adjusting layout for the cell according to its position in the table view
	if ([self _isOnlyRowAtIndexPath:indexPath]) {
		cell.baseLayoutConstraint.constant = -2;
	} else if ([self _isLastRowAtIndexPath:indexPath]) {
		cell.baseLayoutConstraint.constant = 1;
	} else if ([self _isFirstRowAtIndexPath:indexPath]) {
		cell.baseLayoutConstraint.constant = -5;
	} else {
		// any intermidiate row
		cell.baseLayoutConstraint.constant = -2;
	}
}

- (void)_beginLoading {
	[self.refreshControl beginRefreshing];
	
	// dispose existing request if any
	[self.fetchIssuesDisposable dispose];

	@weakify(self);
	self.fetchIssuesDisposable = [[[CRMAPIClient sharedInstance] issuesForApplication:self.application] subscribeNext:^(NSArray *fetchedIssueIDs) {
		@strongify(self);
		self.issueIDs = fetchedIssueIDs;//[self.issueIDs arrayByAddingObjectsFromArray:fetchedIssueIDs];
	} error:^(NSError *error) {
		@strongify(self);
		[self.refreshControl endRefreshing];
	} completed:^{
		@strongify(self);
		[self.refreshControl endRefreshing];
	}];

}

- (CRMIssue *)_issueForIndexPath:(NSIndexPath *)indexPath {
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSInteger)_numberOfIssues {
	id<NSFetchedResultsSectionInfo> sectionInfo  = [self.fetchedResultsController.sections firstObject];
	return sectionInfo.numberOfObjects;
}

- (BOOL)_isOnlyRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row == 0 &&
			[self _numberOfIssues] == 1);
}

- (BOOL)_isFirstRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row == 0 &&
			[self _numberOfIssues] > 0);
}

- (BOOL)_isLastRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([self _numberOfIssues] != 0 &&
			indexPath.row == [self _numberOfIssues] - 1);
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	

	NSAssert(self.application != nil, @"Application is not set");
	
	@weakify(self);
	[RACObserve(self, application) subscribeNext:^(CRMApplication *application) {
		@strongify(self);
		self.fetchedResultsController = [CRMIssue MR_fetchAllGroupedBy:nil
														 withPredicate:[application.filter predicate]
															  sortedBy:nil
															 ascending:YES];
		NSArray *sortDescriptors = @[
			// Impact Level
			[NSSortDescriptor sortDescriptorWithKey:CRMIssueAttributes.impactLevel
										  ascending:NO],
			// Number of crashes
			[NSSortDescriptor sortDescriptorWithKey:CRMIssueAttributes.crashesCount
										  ascending:NO],
			// Number of users affected by the crash
			[NSSortDescriptor sortDescriptorWithKey:CRMIssueAttributes.devicesAffected
										  ascending:NO],
			// Unresolved issues should come before resovled
			// Issues resolved today yesterday should go before issues resolved yesterday
			[NSSortDescriptor sortDescriptorWithKey:CRMIssueAttributes.resolvedAt
										  ascending:YES],
			// As a final meause, we sort by the title
			[NSSortDescriptor sortDescriptorWithKey:CRMIssueAttributes.title
										  ascending:NO
										   selector:@selector(localizedStandardCompare:)],
		];
		self.fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors;
		
		NSError *error = nil;
		if (![self.fetchedResultsController performFetch:&error]) {
			DDLogError(@"Failed to fetch issues for application %@\n%@", application.name, error);
		}
		
		[self _beginLoading];
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"bugs-filter"]) {
		CRMFiltersViewController *filterViewController = [((UINavigationController *)segue.destinationViewController).viewControllers firstObject];
		filterViewController.application = self.application;
	} else if ([segue.identifier isEqualToString:@"issues-details"]) {
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
		self.navigationItem.backBarButtonItem.title = @"";
		
		CRMIssue *issue = [self _issueForIndexPath:self.tableView.indexPathForSelectedRow];
		CRMIssueDetailsViewController *issueDetailsViewController = segue.destinationViewController;
		issueDetailsViewController.issue = issue;
		issueDetailsViewController.title = issue.title;
	}
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CRMIssueListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IssueCellIdentifier"
															forIndexPath:indexPath];
	[self _configureCell:cell forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	return [self.application.filter summaryString];
}


#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	CRMIssue *issue = [self _issueForIndexPath:indexPath];
    return issue.resolvedAt ? NSLocalizedString(@"CRMIssueListReopenIssue", @"") : NSLocalizedString(@"CRMIssueListCloseIssues", @"") ;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    CRMIssue *issue = [self _issueForIndexPath:indexPath];
    [[CRMAPIClient sharedInstance] setResolved:![issue isResolved]
                                      forIssue:issue];
    
    
    [tableView setEditing:NO animated:YES];
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    [self _configureCell:cell
            forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![self _isOnlyRowAtIndexPath:indexPath] &&
		([self _isFirstRowAtIndexPath:indexPath] ||
		 [self _isLastRowAtIndexPath:indexPath])) {
			return 60.0f;
		}
	return 54.0;
}

@end
