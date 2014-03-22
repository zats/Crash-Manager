//
//  CRMSettingsViewController.m
//  CrashManager
//
//  Created by Sasha Zats on 3/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMSettingsViewController.h"

#import "ADNActivityCollection.h"
#import "CRMConfiguration.h"
#import "CRMAPIClient.h"
#import "UIViewController+OpenSource.h"

typedef NS_ENUM(NSInteger, CRMSections) {
	CRMPushNotificationsSection = 0,
	CRMVersionSection = 1,
    CRMVersionShareSection = 2,
	CRMVersionOpenGithubSection = 3
};


@interface CRMSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *appTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UILabel *openGitHubPageLabel;
@end

@implementation CRMSettingsViewController

#pragma mark - Private

- (void)_configureVersion {
	NSMutableString *versionString = [NSMutableString string];
	NSString *marketingVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	if (marketingVersionString) {
		[versionString appendString:marketingVersionString];
	}
	NSString *shortVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	if (shortVersionString) {
		if ([versionString length]) {
			[versionString appendFormat:@" (%@)", shortVersionString];
		} else {
			[versionString appendString:shortVersionString];
		}
	}
	if (!versionString) {
		[versionString appendString:@"Unknown"];
	}
	
	self.versionLabel.text = versionString;
}

- (void)_configureAppName {
	self.appTitleLabel.text = [[CRMConfiguration sharedInstance] appDisplayName];
}

- (void)_configureCells {
	[self _configureVersion];
	[self _configureAppName];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self crm_exposeSource];
	
	[self _configureCells];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == CRMVersionSection) {
		return NO;
	}
	return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	switch ((CRMSections)indexPath.section) {
		case CRMVersionOpenGithubSection: {
			[[UIApplication sharedApplication] openURL:[[CRMConfiguration sharedInstance] gitHubPageURL]];
			break;
		}
			
		case CRMVersionShareSection: {
			NSString *shareString = [NSString stringWithFormat:NSLocalizedString(@"CRMSharingFormatString", nil), [[CRMConfiguration sharedInstance] appDisplayName]];
			NSArray *activityItems = @[ shareString, [[CRMConfiguration sharedInstance] marketingURL] ];
			UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
																								 applicationActivities:[ADNActivityCollection allActivities]];
			[self presentViewController:activityViewController
							   animated:YES
							 completion:nil];
			
			break;
		}
			
		default:
			break;
	}
}

@end
