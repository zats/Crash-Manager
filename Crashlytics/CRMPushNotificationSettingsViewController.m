//
//  CRMPushNotificationSettingsViewController.m
//  CrashManager
//
//  Created by Sasha Zats on 3/21/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMPushNotificationSettingsViewController.h"

#import "CRMPushNotificationSettingTableViewCell.h"
#import "CRMApplication.h"
#import "CRMOrganization.h"
#import "CRMAPIClient.h"

@interface CRMPushNotificationSettingsViewController () <CRMPushNotificationSettingTableViewCellDelegate>

@end

@implementation CRMPushNotificationSettingsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fetchedResultsController = [CRMApplication MR_fetchAllGroupedBy:nil//CRMApplicationRelationships.organization
                                                           withPredicate:nil
                                                                sortedBy:nil
                                                               ascending:YES];
    self.fetchedResultsController.fetchRequest.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:CRMApplicationAttributes.name
                                     ascending:YES
                                      selector:@selector(localizedCaseInsensitiveCompare:)],
        [NSSortDescriptor sortDescriptorWithKey:CRMApplicationAttributes.bundleID
                                     ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:CRMApplicationAttributes.impactedDevicesCount
                                     ascending:NO]];
    
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *const CellIdentifier = @"PushNotificationCellIdentifier";
	CRMPushNotificationSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                                    forIndexPath:indexPath];
    cell.delegate = self;
	CRMApplication *app = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.applicationNameLabel.text = app.name;
    
	return cell;
}

#pragma mark - CRMPushNotificationSettingTableViewCellDelegate

- (void)pushNotificationSettingTableViewCell:(CRMPushNotificationSettingTableViewCell *)cell
                        didChangeSwitchValue:(BOOL)newValue {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CRMApplication *application = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [[[CRMAPIClient sharedInstance] validateWebhookForApplication:application]
        subscribeNext:^(id x) {
    
        } error:^(NSError *error) {
            
        }];
}

@end
