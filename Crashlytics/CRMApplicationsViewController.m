//
//  CRMApplicationsViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/8/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMApplicationsViewController.h"

#import "CRMAPIClient.h"
#import "CRMAccount.h"
#import "CRMApplication.h"
#import "CRMApplicationCell.h"
#import "CRMBuild.h"
#import "CRMIssuesViewController.h"
#import "CRMOrganization.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <TTTLocalizedPluralString/TTTLocalizedPluralString.h>

@interface CRMApplicationsViewController ()

@property (nonatomic, strong) NSString *orgnaizationID;

@end

@implementation CRMApplicationsViewController

#pragma mark - Public

- (void)setOrganization:(CRMOrganization *)organization {
	self.orgnaizationID = organization.organizationID;
}

- (CRMOrganization *)organization {
	CRMOrganization *organization = [CRMOrganization MR_findFirstByAttribute:CRMOrganizationAttributes.organizationID
																   withValue:self.orgnaizationID];
	return organization;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	@weakify(self);
	
    RACSignal *organizationDidChangeSignal = [RACObserve(self, organization) filter:^BOOL(CRMOrganization *organization) {
		return organization != nil;
	}];
	RACSignal *activeAccountDidChangeSignal = [[CRMAccount activeAccountChangedSignal] filter:^BOOL(id account) {
		return account != nil;
	}];
	
	[[RACSignal combineLatest:@[ organizationDidChangeSignal, activeAccountDidChangeSignal]]
        subscribeNext:^(id x) {
            @strongify(self);
            [[CRMAPIClient sharedInstance] applicationsForOrganization:self.organization];
        }];
	
	[organizationDidChangeSignal subscribeNext:^(id x) {
        @strongify(self);
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K.%K == %@", CRMApplicationRelationships.organization, CRMOrganizationAttributes.organizationID, self.orgnaizationID];
		self.fetchedResultsController = [CRMApplication MR_fetchAllGroupedBy:nil
															   withPredicate:predicate
																	sortedBy:CRMApplicationAttributes.name
																   ascending:YES];
		self.fetchedResultsController.fetchRequest.sortDescriptors = @[
			[NSSortDescriptor sortDescriptorWithKey:CRMApplicationAttributes.name
										  ascending:YES
										   selector:@selector(localizedCaseInsensitiveCompare:)],
			[NSSortDescriptor sortDescriptorWithKey:CRMApplicationAttributes.bundleID
										  ascending:YES],
			[NSSortDescriptor sortDescriptorWithKey:CRMApplicationAttributes.impactedDevicesCount
										  ascending:NO],
		];
		[self.fetchedResultsController performFetch:nil];
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
	CRMApplication *selectedApplcation = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];

	if ([segue.identifier isEqualToString:@"applications-issues"]) {
		CRMIssuesViewController *issuesTableViewController = segue.destinationViewController;
		
		issuesTableViewController.title = [NSString stringWithFormat:NSLocalizedString(@"CRMIssueListTitleFormat", @"Format for the title of the issues list screen, application name will be substituded"), selectedApplcation.name];
		issuesTableViewController.application = selectedApplcation;
	}
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CRMApplicationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ApplicationCellIdentifier"
															   forIndexPath:indexPath];
	
	CRMApplication *application = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.applicationNameLabel.text = application.name;
	cell.applicationNameLabel.textColor = [application.status isEqualToString:@"activated"] ? [UIColor blackColor] : [UIColor lightGrayColor];
	cell.applicationBundleIDLabel.text = [NSString stringWithFormat:@"%@  %@", application.bundleID, application.latestBuild ?: @""];
	NSString *detailsString = [NSString stringWithFormat:@"%@  ", application.platform];
	if (application.impactedDevicesCountValue) {
		NSString *numberOfIssues = [NSString stringWithFormat:TTTLocalizedPluralString(application.unresolvedIssuesCountValue, @"CRMApplicationsListIssueCount", @"number of issues in the applications list screen"), application.unresolvedIssuesCount];
		NSString *numberOfUsers = [NSString stringWithFormat:TTTLocalizedPluralString(application.impactedDevicesCountValue, @"CRMApplicationsListUsersAffected", @"number of impacted users in the applications list screen"), application.impactedDevicesCount];
		detailsString = [detailsString stringByAppendingFormat:@"%@  %@", numberOfIssues, numberOfUsers];
	} else {
		detailsString = [detailsString stringByAppendingString:NSLocalizedString(@"CRMApplicationsListNoIssues", @"Status text for when application has no issues on the applications list screen")];
	}
	cell.applicationDetailsLabel.text = detailsString;
    NSURL *iconURL = [NSURL URLWithString:application.iconURLString];
    UIImage *placeholderImage = [UIImage imageNamed:@"app-icon-placeholder"];
    [cell.applicationIconImageView setImageWithURL:iconURL
                                  placeholderImage:placeholderImage];
	if ([self isOnlyRowInSectionAtIndexPath:indexPath]) {
		cell.baseLayoutConstraint.constant = 0;
	} else if ([self isLastRowInSectionAtIndexPath:indexPath]) {
		cell.baseLayoutConstraint.constant = 2;
	} else if ([self isFirstRowInSectionAtIndexPath:indexPath]) {
		cell.baseLayoutConstraint.constant = -2;
	} else {
		// any intermidiate row
		cell.baseLayoutConstraint.constant = 0;
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![self isOnlyRowInSectionAtIndexPath:indexPath] &&
		([self isFirstRowInSectionAtIndexPath:indexPath] ||
		 [self isLastRowInSectionAtIndexPath:indexPath])) {
		return 64.0f;
	}
	return 60.0f;
}

@end
