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
#import "CRMIssueCell.h"
#import "CRMIssuesDefaultDataSource.h"
#import "CRMRecentIssuesDataSource.h"
#import "UIViewController+OpenSource.h"
#import <TTTLocalizedPluralString/TTTLocalizedPluralString.h>

@interface CRMIssuesViewController ()
@property (nonatomic, strong) RACDisposable *fetchIssuesDisposable;
@property (nonatomic, strong) CRMIssuesDataSource *dataSource;
@end

@implementation CRMIssuesViewController

#pragma mark - Actions

- (IBAction)_refreshControlHandler:(id)sender {
	[self _beginLoading];
}

- (IBAction)_unwindFiltersViewController:(UIStoryboardSegue *)segue {
//	NSPredicate *newPredicate = [self.application.filter predicate];
//	BOOL hasPredicateChanged = ![self.fetchedResultsController.fetchRequest.predicate isEqual:newPredicate];
//	if (!hasPredicateChanged) {
//		return;
//	}
//	self.fetchedResultsController.fetchRequest.predicate = newPredicate;
//	NSError *error = nil;
//	if (![self.fetchedResultsController performFetch:&error]) {
//		DDLogError(@"Failed to fetch with predicate: %@ for filter %@\n%@", newPredicate,self.application.filter, error);
//	}
//	[self.tableView reloadData];
//	[self _beginLoading];
}

#pragma mark - Private

- (void)_beginLoading {
	[self.refreshControl beginRefreshing];
	
	// dispose existing request if any
    [self.fetchIssuesDisposable dispose];
    self.fetchIssuesDisposable = nil;

	@weakify(self);
	self.fetchIssuesDisposable = [[[CRMAPIClient sharedInstance] issuesForApplication:self.application] subscribeNext:^(NSArray *fetchedIssueIDs) {
		@strongify(self);
        if ([self.dataSource isKindOfClass:[CRMRecentIssuesDataSource class]]) {
            ((CRMRecentIssuesDataSource *)self.dataSource).issues = fetchedIssueIDs;
        }
        NSAssert(self.dataSource, @"No data source is set!");
	} error:^(NSError *error) {
		@strongify(self);
		[self.refreshControl endRefreshing];
	} completed:^{
		@strongify(self);
		[self.refreshControl endRefreshing];
	}];

}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSAssert(self.application != nil, @"Application is not set");
    [self crm_exposeSource];
	
	@weakify(self);
    RACSignal *timeRangeFilterChangedSignal = [RACSignal combineLatest:@[ RACObserve(self, application.filter.issueOlderThen), RACObserve(self, application.filter.issueNewerThen)]];
    RACSignal *filterChangedSignal = [[RACSignal combineLatest:@[
            RACObserve(self, application.filter.build),
            RACObserve(self, application.filter.issueStatus),
            timeRangeFilterChangedSignal]]
        distinctUntilChanged];
    [filterChangedSignal
        subscribeNext:^(RACTuple *tuple) {
            @strongify(self);
            self.navigationItem.prompt = [self.application.filter displayString];
            
            // setup a new data source if needed
            if ([self.application.filter isTimeRangeFilterEnabled]) {
                if (![self.dataSource isKindOfClass:[CRMRecentIssuesDataSource class]]) {
                    self.dataSource = [[CRMRecentIssuesDataSource alloc] initWithTableView:self.tableView];
                }
            } else {
                if (![self.dataSource isKindOfClass:[CRMIssuesDefaultDataSource class]]) {
                    CRMIssuesDefaultDataSource *dataSource = [[CRMIssuesDefaultDataSource alloc] initWithTableView:self.tableView
                                                                                                       application:self.application
                                                                                               filterChangedSignal:filterChangedSignal];
                    self.dataSource = dataSource;
                }
            }

            [self _beginLoading];
        }];
    
    [RACObserve(self, dataSource) subscribeNext:^(id x) {
        @strongify(self);
        self.tableView.dataSource = self.dataSource;
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"bugs-filter"]) {
		CRMFiltersViewController *filterViewController = [((UINavigationController *)segue.destinationViewController).viewControllers firstObject];
		filterViewController.application = self.application;
	} else if ([segue.identifier isEqualToString:@"issues-details"]) {
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
		self.navigationItem.backBarButtonItem.title = @"";
		
		CRMIssue *issue = [self.dataSource issueForIndexPath:self.tableView.indexPathForSelectedRow];
		CRMIssueDetailsViewController *issueDetailsViewController = segue.destinationViewController;
		issueDetailsViewController.issue = issue;
		issueDetailsViewController.title = issue.title;
	}
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	CRMIssue *issue = [self.dataSource issueForIndexPath:indexPath];
    return issue.resolvedAt ? NSLocalizedString(@"CRMIssueListReopenIssue", @"") : NSLocalizedString(@"CRMIssueListCloseIssues", @"") ;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    CRMIssue *issue = [self.dataSource issueForIndexPath:indexPath];
    [[CRMAPIClient sharedInstance] setResolved:![issue isResolved]
                                      forIssue:issue];
    
    
    [tableView setEditing:NO animated:YES];
    id cell = [tableView cellForRowAtIndexPath:indexPath];

    [self.dataSource configureCell:cell
                         withIssue:issue
                         indexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![self.dataSource isOnlyRowAtIndexPath:indexPath] &&
		([self.dataSource isFirstRowAtIndexPath:indexPath] ||
		 [self.dataSource isLastRowAtIndexPath:indexPath])) {
			return 60.0f;
		}
	return 54.0;
}

@end
