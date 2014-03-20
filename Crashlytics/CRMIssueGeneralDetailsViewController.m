//
//  CRMDeviceDetailsViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/26/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMIssueGeneralDetailsViewController.h"

#import "CRMIncident.h"
#import "CRMIncident_Session+Crashlytics.h"
#import "CRMLogViewController.h"
#import "UIViewController+OpenSource.h"
#import <SHAlertViewBlocks/SHAlertViewBlocks.h>

typedef NS_ENUM(NSInteger, CRMSections) {
	kCRMSSectionGeneral = 0,
    kCRMSectionDevice,
    kCRMSectionOS,
    kCRMSectionKeys,
    kCRMSectionLogs
};

typedef NS_ENUM(NSInteger, CRMGeneralSection) {
	kCRMGeneralSectionSignal = 0,
    kCRMGeneralSectionUser
};

typedef NS_ENUM(NSInteger, CRMDeviceSection) {
	kCRMDeviceModel = 0,
    kCRMDeviceOrientation,
    kCRMDeviceProximity,
    kCRMDeviceBattery,
    kCRMDeviceRam,
    kCRMDeviceDiskSpace,
};

typedef NS_ENUM(NSInteger, CRMOperatingSystemSection) {
	kCRMOperatingSystemVersion = 0,
    kCRMOperatingSystemJailbroken,
    kCRMOperatingSystemLanguage
};

@interface CRMIssueGeneralDetailsViewController ()
@end

@implementation CRMIssueGeneralDetailsViewController

#pragma mark - Private

- (void)_configureGeneralCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	switch ((CRMGeneralSection)indexPath.row) {
		case kCRMGeneralSectionSignal: {
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowSignal", nil);
			cell.detailTextLabel.text = [[self.session lastEvent].app.execution.signal displayString];
			break;
		}
			
		case kCRMGeneralSectionUser: {
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowUser", nil);
			NSString *userDisplayString = [self.session.user displayString];
			if (!userDisplayString) {
				cell.detailTextLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowValueUnknown", nil);
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
			} else {
				cell.detailTextLabel.text = userDisplayString;
			}
			break;
		}
	}
}


- (void)_configureDeviceCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	switch ((CRMDeviceSection)indexPath.row) {
		case kCRMDeviceBattery: {
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowBattery", nil);
			NSString *batteryLevel = [[self.session lastEvent].device batteryDisplayString];
			if (!batteryLevel) {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowValueNA", nil);
			} else {
				cell.detailTextLabel.text = batteryLevel;
			}
			break;
		}
			
		case kCRMDeviceDiskSpace:
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowDiskSpace", nil);
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%%", [self.session deviceAvailableDiskSpacePercentage]];
			break;
			
		case kCRMDeviceModel: {
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowModel", nil);
			NSString *model = [self.session.device displayString];
			if (!model) {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowValueUnknown", nil);
			} else {
				cell.detailTextLabel.text = model;
			}
			break;
		}
			
		case kCRMDeviceOrientation: {
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowOrientation", nil);
			NSString *orienation = [[self.session lastEvent].device orientationDisplayString];
			if (!orienation) {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowValueNA", nil);
			} else {
				cell.detailTextLabel.text = orienation;
			}
			break;
		}
			
		case kCRMDeviceProximity:
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowProximity", nil);
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.session lastEvent].device.proximityOn ? NSLocalizedString(@"CRMIssueGeneralDetailsRowValueOn", nil) : NSLocalizedString(@"CRMIssueGeneralDetailsRowValueOff", nil)];
			break;
			
		case kCRMDeviceRam:
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowRam", nil);
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%%", [self.session deviceAvailableRamPercentage]];
			break;
	}
}

- (void)_configureOperatingSystemCell:(UITableViewCell *)cell
						 forIndexPath:(NSIndexPath *)indexPath {
	switch ((CRMOperatingSystemSection)indexPath.row) {
		case kCRMOperatingSystemVersion:
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowOS", nil);
			cell.detailTextLabel.text = [self.session.os displayString];
			break;
			
		case kCRMOperatingSystemJailbroken:
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowJailbroken", nil);
			cell.detailTextLabel.text = self.session.os.jailbroken ? @"Yes" : @"No";
			break;
			
		case kCRMOperatingSystemLanguage:
			cell.textLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowLanguage", nil);
			if ([self.session.device.language length]) {
				cell.detailTextLabel.text = self.session.device.language;
			} else {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = NSLocalizedString(@"CRMIssueGeneralDetailsRowValueUnknown", nil);
			}
		default:
			break;
	}
}

#pragma mark - UIViewController 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"issueDetails-log"]) {
		CRMLogViewController *loginViewController = segue.destinationViewController;
		loginViewController.session = self.session;
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch ((CRMSections)section) {
		case kCRMSSectionGeneral: {
			return 2;
		}
		case kCRMSectionDevice:
			return 6;
			
		case kCRMSectionOS:
			return 3;
			
		case kCRMSectionKeys:
			return [[self.session lastEvent].app.customAttributes count];
			
		case kCRMSectionLogs:
			return [[self.session lastEvent].log.content length] ? 1 : 0;
	}
}

- (void)_configureKeyCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
	CRMSessionCustomAttribute *attribute = [[self.session lastEvent].app customAttributesAtIndex:indexPath.row];
	cell.textLabel.text = attribute.key;
	cell.detailTextLabel.text = attribute.value;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = (indexPath.section == kCRMSectionLogs) ? @"DrillDownCell" : @"RegularCellIdentifier";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
															forIndexPath:indexPath];
	cell.detailTextLabel.textColor = [UIColor blackColor];
	cell.detailTextLabel.text = nil;
	cell.textLabel.text = nil;

	switch ((CRMSections)indexPath.section) {
		case kCRMSSectionGeneral: {
			[self _configureGeneralCell:cell forIndexPath:indexPath];
			break;
		}
		case kCRMSectionDevice: {
			[self _configureDeviceCell:cell forIndexPath:indexPath];
			break;
		}
		case kCRMSectionOS: {
			[self _configureOperatingSystemCell:cell forIndexPath:indexPath];
			break;
		}
		case kCRMSectionKeys: {
			[self _configureKeyCell:cell forIndexPath:indexPath];
			break;
		}
		case kCRMSectionLogs: {
			cell.textLabel.text = @"Logs";
		}
	}

	return cell;
	
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	switch ((CRMSections)section) {
		case kCRMSSectionGeneral:
            
			return NSLocalizedString(@"CRMIssueGeneralDetailsSectionGeneral", @"");

		case kCRMSectionDevice:
			return NSLocalizedString(@"CRMIssueGeneralDetailsSectionDevice", @"");
			
		case kCRMSectionOS:
			return NSLocalizedString(@"CRMIssueGeneralDetailsSectionOS", @"");
			
		case kCRMSectionKeys:
			return [[self.session lastEvent].app.customAttributes count] ? NSLocalizedString(@"CRMIssueGeneralDetailsSectionKeys", @"") : nil;

		case kCRMSectionLogs:
			return [[self.session lastEvent].log.content length] ? NSLocalizedString(@"CRMIssueGeneralDetailsSectionLogs", @"") : nil;
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section {
	switch ((CRMSections)section) {
		case kCRMSSectionGeneral:
		case kCRMSectionDevice:
		case kCRMSectionOS:
			return nil;
			
		case kCRMSectionKeys:
            
			return [[self.session lastEvent].app.customAttributes count] ? nil : NSLocalizedString(@"CRMIssueGeneralDetailsNoKeysMessage", @"");
			
		case kCRMSectionLogs:
			return [[self.session lastEvent].log.content length] ? nil : NSLocalizedString(@"CRMIssueGeneralDetailsNoLogsMessage", @"");
	}
	return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kCRMSectionLogs) {
		// being handled by storyboard
		return;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	UIAlertView *alert = [UIAlertView SH_alertViewWithTitle:cell.textLabel.text
												withMessage:cell.detailTextLabel.text];
	[alert SH_addButtonWithTitle:@"Copy" withBlock:^(NSInteger theButtonIndex) {
		[[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"%@ %@", cell.textLabel.text, cell.detailTextLabel.text]];
	}];
	[alert SH_addButtonCancelWithTitle:@"Cancel" withBlock:nil];
	[alert show];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		[[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"%@ %@", cell.textLabel.text, cell.detailTextLabel.text]];
	}
}

@end
