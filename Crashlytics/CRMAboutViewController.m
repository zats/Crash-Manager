//
//  CRMAboutViewController.m
//  CrashManager
//
//  Created by Sasha Zats on 3/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMAboutViewController.h"

#import "ADNActivityCollection.h"
#import "CRMConfiguration.h"
#import "UIViewController+OpenSource.h"

typedef NS_ENUM(NSInteger, CRMSections) {
	CRMVersionSection = 0,
    CRMVersionShareSection = 1,
	CRMVersionOpenGithubSection = 2
};


@interface CRMAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *appTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UILabel *openGitHubPageLabel;
@end

@implementation CRMAboutViewController

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
	if (indexPath.section == CRMVersionShareSection ||
		indexPath.section == CRMVersionOpenGithubSection) {
		return YES;
	}
	return NO;
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
