//
//  CLSAboutViewController.m
//  CrashManager
//
//  Created by Sasha Zats on 3/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CLSAboutViewController.h"

#import "UIViewController+OpenSource.h"

@interface CLSAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation CLSAboutViewController

- (void)_configureCells {
	NSMutableString *versionString = [NSMutableString string];
	NSString *marketingVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	if (marketingVersionString) {
		[versionString appendString:marketingVersionString];
	}
	NSString *shortVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	if (shortVersionString) {
		if ([versionString length]) {
			[versionString appendFormat:@" (shortVersionString)"];
		} else {
			[versionString appendString:shortVersionString];
		}
	}
	if (!versionString) {
		[versionString appendString:@"Unknown"];
	}
	
	self.versionLabel.text = versionString;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	[self cls_exposeSource];
	
	[self _configureCells];
}

@end
