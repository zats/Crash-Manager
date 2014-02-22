//
//  CLSBugsViewController.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/22/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSIssuesViewController.h"

#import "CLSAPIClient.h"
#import "CLSAccount.h"
#import "CLSFilter.h"
#import "CLSApplication.h"
#import "CLSBuild.h"
#import "CLSFiltersViewController.h"
#import "CLSIssue.h"
#import "CLSIssueDetailsViewController.h"
#import "CLSIssueListCell.h"
#import <TTTLocalizedPluralString/TTTLocalizedPluralString.h>

@interface CLSIssuesViewController () <CLSFilterViewControllerDelegate>
@property (nonatomic, strong) NSString *applicationID;
@property (nonatomic, strong) NSPredicate *basicPredicate;
@property (nonatomic, strong) RACDisposable *fetchIssuesDisposable;
@property (nonatomic, strong) NSArray *issueIDs;
@end

@implementation CLSIssuesViewController

#pragma mark - Public

- (void)setApplication:(CLSApplication *)application {
	self.applicationID = application.applicationID;
}

- (CLSApplication *)application {
	return [CLSApplication MR_findFirstByAttribute:CLSApplicationAttributes.applicationID
										 withValue:self.applicationID];
}

#pragma mark - Actions

- (IBAction)_refreshControlHandler:(id)sender {
	[self _beginLoading];
}

#pragma mark - Private

- (void)_configureCell:(CLSIssueListCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	CLSIssue *issue = [self _issueForIndexPath:indexPath];
	cell.issueNumberLabel.text = [issue.displayID description];
	cell.issueTitleLabel.textColor = [issue isResolved] ? [UIColor lightGrayColor] : [UIColor blackColor];
	cell.issueTitleLabel.text = issue.title;
	cell.issueSubtitleLabel.text = issue.subtitle;
	cell.impactLevelImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"issue-impact-level-%@", issue.impactLevel]];
	
	NSString *crashesString = TTTLocalizedPluralString(issue.crashesCountValue, @"CLSIssueListCrashesCount", @"Crashes count for issues list screen");
	NSString *usersAffected = TTTLocalizedPluralString(issue.devicesAffectedValue, @"CLSIssueListUsersAffected", @"Users affected count for issues list screen");
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
	self.fetchIssuesDisposable = [[[CLSAPIClient sharedInstance] issuesForApplication:self.application] subscribeNext:^(NSArray *fetchedIssueIDs) {
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

- (CLSIssue *)_issueForIndexPath:(NSIndexPath *)indexPath {
	NSAssert(indexPath.row < [self.issueIDs count], @"Specified index path is out of bounds of issue IDs: %@ %@", indexPath, self.issueIDs);
	NSString *issueID = self.issueIDs[indexPath.row];
	return [CLSIssue MR_findFirstByAttribute:CLSIssueAttributes.issueID
								   withValue:issueID];
}

- (BOOL)_isOnlyRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row == 0 &&
			[self.issueIDs count] == 1);
}

- (BOOL)_isFirstRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row == 0 &&
			[self.issueIDs count] > 0);
}

- (BOOL)_isLastRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([self.issueIDs count] != 0 &&
			indexPath.row == [self.issueIDs count] - 1);
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	NSAssert(self.application != nil, @"Application is not set");
	
	@weakify(self);
	[[RACObserve(self.application, filter)
		filter:^BOOL(CLSApplication *application) {
			return application != nil;
		}]
		subscribeNext:^(CLSFilter *filter) {
			[[[RACSignal
				combineLatest:@[
                    RACObserve(filter, build),
                    RACObserve(filter, issueStatus),
                    RACObserve(filter, issueNewerThen),
                    RACObserve(filter, issueOlderThen)]]
				distinctUntilChanged]
				subscribeNext:^(id x) {
					// We don't get issues creation date in response we can not use
					// fetched results controller for fetching issues filtered by time.
					// Because of that I ended up using a simple array for this case
					// However we still trying to prepopulate array for other fitlers
					// or for whe no filters selected
					@strongify(self);
					CLSFilter *filter = self.application.filter;
					if ([filter isTimeRangeFilterSet]) {
						self.issueIDs = [NSArray array];
					} else {
						NSMutableArray *predicatesArray = [NSMutableArray array];
						if ([filter isBuildFilterSet]) {
							[predicatesArray addObject:[NSPredicate predicateWithFormat:@"%K == %@", CLSIssueRelationships.build, filter.build]];
						}
						if ([filter isStatusFilterSet]) {
							if ([filter.issueStatus isEqualToString:CLSFilterIssueStatusResolved]) {
								[predicatesArray addObject:[NSPredicate predicateWithFormat:@"%K != nil", CLSIssueAttributes.resolvedAt]];
							} else if ([filter.issueStatus isEqualToString:CLSFilterIssueStatusUnresolved]) {
								[predicatesArray addObject:[NSPredicate predicateWithFormat:@"%K == nil", CLSIssueAttributes.resolvedAt]];
							}
						}
						[predicatesArray addObject:[NSPredicate predicateWithFormat:@"%K == %@", CLSIssueRelationships.application, self.application]];
						NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
						NSString *sortString = [NSString stringWithFormat:@"%@,%@,%@", CLSIssueAttributes.crashesCount, CLSIssueAttributes.devicesAffected, CLSIssueAttributes.title];
						NSArray *issues = [CLSIssue MR_findAllSortedBy:sortString ascending:NO withPredicate:predicate];
						self.issueIDs = [issues valueForKey:CLSIssueAttributes.issueID];
					}
					[self _beginLoading];
				}];
		}];
	
	[RACObserve(self, issueIDs) subscribeNext:^(id x) {
		@strongify(self);
		[self.tableView reloadData];
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"bugs-filter"]) {
		CLSFiltersViewController *filterViewController = [((UINavigationController *)segue.destinationViewController).viewControllers firstObject];
		filterViewController.application = self.application;
		filterViewController.delegate = self;
	} else if ([segue.identifier isEqualToString:@"issues-details"]) {
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
		self.navigationItem.backBarButtonItem.title = @"";
		
		CLSIssue *issue = [self _issueForIndexPath:self.tableView.indexPathForSelectedRow];
		CLSIssueDetailsViewController *issueDetailsViewController = segue.destinationViewController;
		issueDetailsViewController.issue = issue;
		issueDetailsViewController.title = issue.title;
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.issueIDs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CLSIssueListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IssueCellIdentifier"
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
	CLSIssue *issue = [self _issueForIndexPath:indexPath];
    return issue.resolvedAt ? NSLocalizedString(@"CLSIssueListReopenIssue", @"") : NSLocalizedString(@"CLSIssueListCloseIssues", @"") ;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    CLSIssue *issue = [self _issueForIndexPath:indexPath];
    [[CLSAPIClient sharedInstance] setResolved:![issue isResolved]
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

#pragma mark - CLSFilterViewControllerDelegate

- (void)filterViewControllerDidFinish:(CLSFiltersViewController *)filterViewController {
	[filterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
