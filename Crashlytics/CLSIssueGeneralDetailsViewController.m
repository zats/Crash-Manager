//
//  CLSDeviceDetailsViewController.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/26/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSIssueGeneralDetailsViewController.h"

#import "CLSIncident.h"
#import "CLSIncident_Session+Crashlytics.h"
#import "CLSLogViewController.h"
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
@synthesize session = _session;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	@weakify(self);
	[[RACObserve(self, session)
	  filter:^BOOL(id value) {
		  return value != nil;
	  }] subscribeNext:^(id x) {
		  @strongify(self);
		  [self.tableView reloadData];
	  }];
}

#pragma mark - Private

- (void)_configureGeneralCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	switch ((CLSGeneralSection)indexPath.row) {
		case kCLSGeneralSectionSignal: {
			cell.textLabel.text = @"signal";
			cell.detailTextLabel.text = [[self.session lastEvent].app.execution.signal displayString];
			break;
		}
			
		case kCLSGeneralSectionUser: {
			cell.textLabel.text = @"user";
			NSString *userDisplayString = [self.session.user displayString];
			if (!userDisplayString) {
				cell.detailTextLabel.text = @"Unknown";
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
			cell.textLabel.text = @"battery";
			NSString *batteryLevel = [[self.session lastEvent].device batteryDisplayString];
			if (!batteryLevel) {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = @"N/A";
			} else {
				cell.detailTextLabel.text = batteryLevel;
			}
			break;
		}
			
		case kCLSDeviceDiskSpace:
			cell.textLabel.text = @"disk space";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%%", [self.session deviceAvailableDiskSpacePercentage]];
			break;
			
		case kCLSDeviceModel: {
			cell.textLabel.text = @"model";
			NSString *model = [self.session.device displayString];
			if (!model) {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = @"Unknown";
			} else {
				cell.detailTextLabel.text = model;
			}
			break;
		}
			
		case kCLSDeviceOrientation: {
			cell.textLabel.text = @"orientation";
			NSString *orienation = [[self.session lastEvent].device orientationDisplayString];
			if (!orienation) {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = @"N/A";
			} else {
				cell.detailTextLabel.text = orienation;
			}
			break;
		}
			
		case kCLSDeviceProximity:
			cell.textLabel.text = @"proximity";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.session lastEvent].device.proximityOn ? @"On" : @"Off"];
			break;
			
		case kCLSDeviceRam:
			cell.textLabel.text = @"ram";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%%", [self.session deviceAvailableRamPercentage]];
			break;
	}
}

- (void)_configureOperatingSystemCell:(UITableViewCell *)cell
						 forIndexPath:(NSIndexPath *)indexPath {
	switch ((CLSOperatingSystemSection)indexPath.row) {
		case kCLSOperatingSystemVersion:
			cell.textLabel.text = @"os";
			cell.detailTextLabel.text = [self.session.os displayString];
			break;
			
		case kCLSOperatingSystemJailbroken:
			cell.textLabel.text = @"jailbroken";
			cell.detailTextLabel.text = self.session.os.jailbroken ? @"Yes" : @"No";
			break;
			
		case kCLSOperatingSystemLanguage:
			cell.textLabel.text = @"language";
			if ([self.session.device.language length]) {
				cell.detailTextLabel.text = self.session.device.language;
			} else {
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = @"Unknown";
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
	CLSSessionCustomAttribute *attribute = [[self.session lastEvent].app customAttributesAtIndex:indexPath.row];
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
			return @"General";

		case kCLSSectionDevice:
			return @"Device";
			
		case kCLSSectionOS:
			return @"Operating System";
			
		case kCLSSectionKeys:
			return [[self.session lastEvent].app.customAttributes count] ? @"Keys" : nil;

		case kCLSSectionLogs:
			return [[self.session lastEvent].log.content length] ? @"Logs" : nil;
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
			return [[self.session lastEvent].app.customAttributes count] ? nil : @"No keys were set, please see the documentation to add custom keys.";
			
		case kCLSSectionLogs:
			return [[self.session lastEvent].log.content length] ? nil : @"No logs were supplied, please see the documentation to add logs.";
	}
	return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kCLSSectionLogs) {
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
