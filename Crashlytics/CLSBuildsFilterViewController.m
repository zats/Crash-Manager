//
//  CLSBuildsTableViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/21/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSBuildsFilterViewController.h"

#import "CLSAPIClient.h"
#import "CRMBuild.h"
#import "CRMFilter.h"
#import "CRMApplication.h"
#import "CRMAccount.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface CLSBuildsFilterViewController ()
@end

@implementation CLSBuildsFilterViewController

- (IBAction)_filterBarButtonItemHandler:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	RACSignal *applicationDidChangeSignal = [RACObserve(self.filter, application) filter:^BOOL(CRMApplication *application) {
		return application != nil;
	}];
	RACSignal *activeAccountDidChangeSignal = [[CRMAccount activeAccountChangedSignal] filter:^BOOL(id account) {
		return account != nil;
	}];
	
	// Refetching builds list
	[[RACSignal
		combineLatest:@[ applicationDidChangeSignal, activeAccountDidChangeSignal]]
		subscribeNext:^(id x) {
			[[CLSAPIClient sharedInstance] buildsForApplication:self.filter.application];
		}];
	
	// Updating fetch results controller
	[applicationDidChangeSignal subscribeNext:^(id x) {
		// All builds of the current application
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K.%K == %@", CLSBuildRelationships.application, CLSApplicationAttributes.applicationID, self.filter.application.applicationID];
		
		self.fetchedResultsController = [CRMBuild MR_fetchAllGroupedBy:nil
														 withPredicate:predicate
															  sortedBy:nil
															 ascending:NO];
		
		self.fetchedResultsController.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:CLSBuildAttributes.buildID
																									 ascending:NO
																									  selector:@selector(localizedStandardCompare:)]];
		[self.fetchedResultsController performFetch:nil];
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	}
	id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[0];
	return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BuildCellIdentifier"
															forIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		cell.textLabel.text = @"All Builds";
		cell.accessoryType = self.filter.build ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
	} else {
		CRMBuild *build = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
																							  inSection:0]];
		cell.textLabel.text = build.buildID;
		cell.accessoryType = (self.filter.build == build) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	// Previously selected index path
	NSIndexPath *previouslySelectedIndexPath = [self.fetchedResultsController indexPathForObject:self.filter.build];
	if (previouslySelectedIndexPath) {
		// adjust index path if it was found,
		previouslySelectedIndexPath = [NSIndexPath indexPathForRow:previouslySelectedIndexPath.row
														 inSection:1];
	} else {
		previouslySelectedIndexPath = [NSIndexPath indexPathForRow:0
														 inSection:0];
	}
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:previouslySelectedIndexPath];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	
	CRMBuild *build = nil;
	if (indexPath.section == 1) {
		build = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
																					inSection:0]];
	}
	self.filter.build = build;
	[self.filter.managedObjectContext MR_saveToPersistentStoreAndWait];

	cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - CLSTableViewController

- (NSInteger)coreDataSectionForDisplaySection:(NSInteger)section {
	return section + 1;
}

- (NSInteger)displaySectionForCoreDataSection:(NSInteger)section {
	return section - 1;
}

- (NSIndexPath *)coreDataIndexPathForDisplayIndexPath:(NSIndexPath *)indexPath {
	return [NSIndexPath indexPathForRow:indexPath.row
							  inSection:indexPath.section + 1];
}

- (NSIndexPath *)displayIndexPathForCoreDataIndexPath:(NSIndexPath *)indexPath {
	return [NSIndexPath indexPathForRow:indexPath.row
							  inSection:indexPath.section - 1];
}

@end
