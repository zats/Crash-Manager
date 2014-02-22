//
//  CLSApplicationsViewController.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/8/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSApplicationsViewController.h"

#import "CLSAPIClient.h"
#import "CLSAccount.h"
#import "CLSApplication.h"
#import "CLSApplicationCell.h"
#import "CLSBuild.h"
#import "CLSIssuesViewController.h"
#import "CLSOrganization.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <TTTLocalizedPluralString/TTTLocalizedPluralString.h>

@interface CLSApplicationsViewController ()

@property (nonatomic, strong) NSString *orgnaizationID;

@end

@implementation CLSApplicationsViewController

#pragma mark - Public

- (void)setOrganization:(CLSOrganization *)organization {
	self.orgnaizationID = organization.organizationID;
}

- (CLSOrganization *)organization {
	CLSOrganization *organization = [CLSOrganization MR_findFirstByAttribute:CLSOrganizationAttributes.organizationID
																   withValue:self.orgnaizationID];
	return organization;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	RACSignal *organizationDidChangeSignal = [RACObserve(self, organization) filter:^BOOL(CLSOrganization *organization) {
		return organization != nil;
	}];
	RACSignal *activeAccountDidChangeSignal = [[CLSAccount activeAccountChangedSignal] filter:^BOOL(id account) {
		return account != nil;
	}];
	
	[[RACSignal combineLatest:@[
		organizationDidChangeSignal,
		activeAccountDidChangeSignal]]
	 subscribeNext:^(id x) {
		[[CLSAPIClient sharedInstance] applicationsForOrganization:self.organization];
	 }];
	
	[organizationDidChangeSignal subscribeNext:^(id x) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K.%K == %@", CLSApplicationRelationships.organization, CLSOrganizationAttributes.organizationID, self.orgnaizationID];
		self.fetchedResultsController = [CLSApplication MR_fetchAllGroupedBy:nil
															   withPredicate:predicate
																	sortedBy:CLSApplicationAttributes.name
																   ascending:YES];
		self.fetchedResultsController.fetchRequest.sortDescriptors = @[
			[NSSortDescriptor sortDescriptorWithKey:CLSApplicationAttributes.name
										  ascending:YES
										   selector:@selector(localizedCaseInsensitiveCompare:)],
			[NSSortDescriptor sortDescriptorWithKey:CLSApplicationAttributes.bundleID
										  ascending:YES],
			[NSSortDescriptor sortDescriptorWithKey:CLSApplicationAttributes.impactedDevicesCount
										  ascending:NO],
		];
		[self.fetchedResultsController performFetch:nil];
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
	CLSApplication *selectedApplcation = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];

	if ([segue.identifier isEqualToString:@"applications-issues"]) {
		CLSIssuesViewController *issuesTableViewController = segue.destinationViewController;
		
		issuesTableViewController.title = [NSString stringWithFormat:NSLocalizedString(@"CLSIssueListTitleFormat", @"Format for the title of the issues list screen, application name will be substituded"), selectedApplcation.name];
		issuesTableViewController.application = selectedApplcation;
	}
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CLSApplicationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ApplicationCellIdentifier"
															   forIndexPath:indexPath];
	
	CLSApplication *application = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.applicationNameLabel.text = application.name;
	cell.applicationNameLabel.textColor = [application.status isEqualToString:@"activated"] ? [UIColor blackColor] : [UIColor lightGrayColor];
	cell.applicationBundleIDLabel.text = [NSString stringWithFormat:@"%@  %@", application.bundleID, application.latestBuild ?: @""];
	NSString *detailsString = [NSString stringWithFormat:@"%@  ", application.platform];
	if (application.impactedDevicesCountValue) {
		NSString *numberOfIssues = [NSString stringWithFormat:TTTLocalizedPluralString(application.unresolvedIssuesCountValue, @"CLSApplicationsListIssueCount", @"number of issues in the applications list screen"), application.unresolvedIssuesCount];
		NSString *numberOfUsers = [NSString stringWithFormat:TTTLocalizedPluralString(application.impactedDevicesCountValue, @"CLSApplicationsListUsersAffected", @"number of impacted users in the applications list screen"), application.impactedDevicesCount];
		detailsString = [detailsString stringByAppendingFormat:@"%@  %@", numberOfIssues, numberOfUsers];
	} else {
		detailsString = [detailsString stringByAppendingString:NSLocalizedString(@"CLSApplicationsListNoIssues", @"Status text for when application has no issues on the applications list screen")];
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
