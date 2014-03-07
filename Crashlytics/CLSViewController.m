//
//  CLSViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSViewController.h"

#import "CRMLoginViewController.h"
#import "CRMAccount.h"
#import "CRMAnalyticsController.h"
#import "UIViewController+OpenSource.h"

@interface CLSViewController ()
@property (nonatomic, strong) RACSubject *disappearingSubject;
@end

@implementation CLSViewController

#pragma mark - Actions

- (void)_activeAccountDidChangeNotificationHandler:(NSNotification *)note {
	[self _showLoginViewControllerIfNeeded];
}

#pragma mark - Private

- (void)_showLoginViewControllerIfNeeded {
	if (![[CRMAccount activeAccount] canRestoreSession]) {
		[self _showLoginViewController];
	}
}

- (void)_showLoginViewController {
	UINavigationController *loginNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
	[self presentViewController:loginNavigationViewController
					   animated:YES
					 completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self crm_exposeSource];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[CRMAnalyticsController sharedInstance] trackViewController:self];
	
	RACSignal *viewWillDisappearSignal = [self rac_signalForSelector:@selector(viewWillDisappear:)];
	
	[[[CRMAccount activeAccountChangedSignal] takeUntil:viewWillDisappearSignal] subscribeNext:^(id x) {
		[self _showLoginViewControllerIfNeeded];
	}];
}

@end
