//
//  CLSViewController.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSViewController.h"

#import "CLSLoginViewController.h"
#import "CLSAccount.h"
#import "UIViewController+OpenSource.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

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
	if (![[CLSAccount activeAccount] canRestoreSession]) {
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
    [self cls_exposeSource];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
	
	RACSignal *viewWillDisappearSignal = [self rac_signalForSelector:@selector(viewWillDisappear:)];
	
	[[[CLSAccount activeAccountChangedSignal] takeUntil:viewWillDisappearSignal] subscribeNext:^(id x) {
		[self _showLoginViewControllerIfNeeded];
	}];
}

@end
