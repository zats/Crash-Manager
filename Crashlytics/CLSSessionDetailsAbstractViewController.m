//
//  CLSSessionDetailsAbstractViewController.m
//  CrashManager
//
//  Created by Sasha Zats on 2/8/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CLSSessionDetailsAbstractViewController.h"

#import "CRMAnalyticsController.h"
#import "UIViewController+OpenSource.h"

@interface CLSSessionDetailsAbstractViewController ()
@property (nonatomic, strong, readwrite) RACSignal *sessionChangedSignal;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak, readwrite) IBOutlet UITableView *tableView;
@end

@implementation CLSSessionDetailsAbstractViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Expose sources for subclasses
    [self crm_exposeSource];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.sessionChangedSignal = [RACObserve(self, session) distinctUntilChanged];
    
    @weakify(self);

    // Hide table view while we don't have data to show
    RAC(self.tableView, hidden) = [self.sessionChangedSignal map:^id(CRMSession *session) {
        return @(session == nil);
    }];
    
    // Start spinner animation
    RACSignal *noSessionSignal = [self.sessionChangedSignal filter:^BOOL(CRMSession *session) {
        return session == nil;
    }];
    [noSessionSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.activityIndicatorView startAnimating];
    }];

    // Stop spinner animation
    RACSignal *hasSessionSignal = [self.sessionChangedSignal filter:^BOOL(CRMSession *session) {
        return session != nil;
    }];
    [hasSessionSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.activityIndicatorView stopAnimating];
    }];
    
    // Reload table view when new session data arrives
    [hasSessionSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[CRMAnalyticsController sharedInstance] trackViewController:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	// stub implementation
	NSAssert(NO, @"Subclasses must ovveride this");
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// stub implementation
	NSAssert(NO, @"Subclasses must ovveride this");
	return nil;
}

@end
