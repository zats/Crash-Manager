//
//  CLSDeviceDetailsViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/26/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSIssueGeneralDetailsViewController.h"

#import "CRMIncident.h"
#import "CLSIncident_Session+Crashlytics.h"
#import "CLSLogViewController.h"
#import "UIViewController+OpenSource.h"
#import <SHAlertViewBlocks/SHAlertViewBlocks.h>

typedef NS_ENUM(NSInteger, CLSSections) {
	kCLSSectionGeneral = 0,
	kCLSSectionDevice,
	kCLSSectionOS,
	kCLSSectionKeys,
	kCLSSectionLogs
};

typedef NS_ENUM(NSInteger, CLSGeneralSection) {
	kCLSGeneralSectionSignal = 0,
	kCLSGeneralSectionUser
};

typedef NS_ENUM(NSInteger, CLSDeviceSection) {
	kCLSDeviceModel = 0,
	kCLSDeviceOrientation,
	kCLSDeviceProximity,
	kCLSDeviceBattery,
	kCLSDeviceRam,
	kCLSDeviceDiskSpace,
};

typedef NS_ENUM(NSInteger, CLSOperatingSystemSection) {
	kCLSOperatingSystemVersion = 0,
	kCLSOperatingSystemJailbroken,
	kCLSOperatingSystemLanguage
};

@interface CLSIssueGeneralDetailsViewController ()
@end

@implementation CLSIssueGeneralDetailsViewController

#pragma mark - Private

- (void)_configureGeneralCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	switch ((CLSGeneralSection)indexPath.row) {
		case kCLSGeneralSectionSignal: {
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowSignal", nil);
			cell.detailTextLabel.text = [[self.session lastEvent].app.execution.signal displayString];
			break;
		}
			
		case kCLSGeneralSectionUser: {
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowUser", nil);
			NSString *userDisplayString = [self.session.user displayString];
			if (!userDisplayString) {
				cell.detailTextLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowValueUnknown", nil);
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
			} else {
				cell.detailTextLabel.text = userDisplayString;
			}
			break;
		}
	}
}


- (void)_configureDeviceCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	switch ((CLSDeviceSection)indexPath.row) {
		case kCLSDeviceBattery: {
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowBattery", nil);
			NSString *batteryLevel = [[self.session lastEvent].device batteryDisplayString];
			if (!batteryLevel) {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowValueNA", nil);
			} else {
				cell.detailTextLabel.text = batteryLevel;
			}
			break;
		}
			
		case kCLSDeviceDiskSpace:
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowDiskSpace", nil);
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%%", [self.session deviceAvailableDiskSpacePercentage]];
			break;
			
		case kCLSDeviceModel: {
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowModel", nil);
			NSString *model = [self.session.device displayString];
			if (!model) {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowValueUnknown", nil);
			} else {
				cell.detailTextLabel.text = model;
			}
			break;
		}
			
		case kCLSDeviceOrientation: {
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowOrientation", nil);
			NSString *orienation = [[self.session lastEvent].device orientationDisplayString];
			if (!orienation) {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowValueNA", nil);
			} else {
				cell.detailTextLabel.text = orienation;
			}
			break;
		}
			
		case kCLSDeviceProximity:
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowProximity", nil);
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.session lastEvent].device.proximityOn ? NSLocalizedString(@"CLSIssueGeneralDetailsRowValueOn", nil) : NSLocalizedString(@"CLSIssueGeneralDetailsRowValueOff", nil)];
			break;
			
		case kCLSDeviceRam:
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowRam", nil);
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%%", [self.session deviceAvailableRamPercentage]];
			break;
	}
}

- (void)_configureOperatingSystemCell:(UITableViewCell *)cell
						 forIndexPath:(NSIndexPath *)indexPath {
	switch ((CLSOperatingSystemSection)indexPath.row) {
		case kCLSOperatingSystemVersion:
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowOS", nil);
			cell.detailTextLabel.text = [self.session.os displayString];
			break;
			
		case kCLSOperatingSystemJailbroken:
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowJailbroken", nil);
			cell.detailTextLabel.text = self.session.os.jailbroken ? @"Yes" : @"No";
			break;
			
		case kCLSOperatingSystemLanguage:
			cell.textLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowLanguage", nil);
			if ([self.session.device.language length]) {
				cell.detailTextLabel.text = self.session.device.language;
			} else {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = NSLocalizedString(@"CLSIssueGeneralDetailsRowValueUnknown", nil);
			}
		default:
			break;
	}
}

#pragma mark - UIViewController 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"issueDetails-log"]) {
		CLSLogViewController *loginViewController = segue.destinationViewController;
		loginViewController.session = self.session;
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch ((CLSSections)section) {
		case kCLSSectionGeneral: {
			return 2;
		}
		case kCLSSectionDevice:
			return 6;
			
		case kCLSSectionOS:
			return 3;
			
		case kCLSSectionKeys:
			return [[self.session lastEvent].app.customAttributes count];
			
		case kCLSSectionLogs:
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
	
	NSString *cellIdentifier = (indexPath.section == kCLSSectionLogs) ? @"DrillDownCell" : @"RegularCellIdentifier";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
															forIndexPath:indexPath];
	cell.detailTextLabel.textColor = [UIColor blackColor];
	cell.detailTextLabel.text = nil;
	cell.textLabel.text = nil;

	switch ((CLSSections)indexPath.section) {
		case kCLSSectionGeneral: {
			[self _configureGeneralCell:cell forIndexPath:indexPath];
			break;
		}
		case kCLSSectionDevice: {
			[self _configureDeviceCell:cell forIndexPath:indexPath];
			break;
		}
		case kCLSSectionOS: {
			[self _configureOperatingSystemCell:cell forIndexPath:indexPath];
			break;
		}
		case kCLSSectionKeys: {
			[self _configureKeyCell:cell forIndexPath:indexPath];
			break;
		}
		case kCLSSectionLogs: {
			cell.textLabel.text = @"Logs";
		}
	}

	return cell;
	
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	switch ((CLSSections)section) {
		case kCLSSectionGeneral:
            
			return NSLocalizedString(@"CLSIssueGeneralDetailsSectionGeneral", @"");

		case kCLSSectionDevice:
			return NSLocalizedString(@"CLSIssueGeneralDetailsSectionDevice", @"");
			
		case kCLSSectionOS:
			return NSLocalizedString(@"CLSIssueGeneralDetailsSectionOS", @"");
			
		case kCLSSectionKeys:
			return [[self.session lastEvent].app.customAttributes count] ? NSLocalizedString(@"CLSIssueGeneralDetailsSectionKeys", @"") : nil;

		case kCLSSectionLogs:
			return [[self.session lastEvent].log.content length] ? NSLocalizedString(@"CLSIssueGeneralDetailsSectionLogs", @"") : nil;
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section {
	switch ((CLSSections)section) {
		case kCLSSectionGeneral:
		case kCLSSectionDevice:
		case kCLSSectionOS:
			return nil;
			
		case kCLSSectionKeys:
            
			return [[self.session lastEvent].app.customAttributes count] ? nil : NSLocalizedString(@"CLSIssueGeneralDetailsNoKeysMessage", @"");
			
		case kCLSSectionLogs:
			return [[self.session lastEvent].log.content length] ? nil : NSLocalizedString(@"CLSIssueGeneralDetailsNoLogsMessage", @"");
	}
	return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kCLSSectionLogs) {
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
