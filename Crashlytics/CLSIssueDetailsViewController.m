//
//  CLSIssueDetailsViewController.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/23/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSIssueDetailsViewController.h"

#import "CLSIssue.h"
#import "CLSAPIClient.h"
#import "CLSAccount.h"
#import "CLSIncident.h"
#import "CLSIssueExceptionTableViewController.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <SHActionSheetBlocks/SHActionSheetBlocks.h>
#import "CLSIncident_Session+Crashlytics.h"

typedef enum _CLSDetailsSegment {
	kCLSExceptionSegment = 2,
	kCLSThreadsSegment = 1,
	kCLSDeviceSegment = 0,
} CLSDetailsSegment;

@interface CLSIssueDetailsViewController ()

@property (nonatomic, weak) CLSSessionDetailsAbstractViewController *currentDetailsViewController;

// UI
@property (weak, nonatomic) IBOutlet UILabel *exceptionTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *exceptionDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *issueStatusBarButtonItem;
@property (weak, nonatomic) IBOutlet UIView *detailsContainerView;

// Data
@property (nonatomic, strong) NSString *issueID;
@property (nonatomic, strong) CLSSession *session;
@property (nonatomic, weak) CLSSessionEvent *lastEvent;
@end

@implementation CLSIssueDetailsViewController

- (BOOL)automaticallyAdjustsScrollViewInsets {
	return NO;
}

- (void)setIssue:(CLSIssue *)issue {
	self.issueID = issue.issueID;
}

- (CLSIssue *)issue {
	return [CLSIssue MR_findFirstByAttribute:CLSIssueAttributes.issueID
								   withValue:self.issueID];
}

#pragma mark - Actions

- (IBAction)_segmentedControlHandler:(UISegmentedControl *)sender {
	[self _setSelectedSection:sender.selectedSegmentIndex];
}

- (IBAction)_actionsBarButtonItemHandler:(id)sender {
	NSURL *URL = [self.issue URL];
	
	UIActionSheet *action = [UIActionSheet SH_actionSheetWithTitle:nil];
	[action SH_addButtonWithTitle:@"Open in Safari" withBlock:^(NSInteger theButtonIndex) {
		[[UIApplication sharedApplication] openURL:URL];
	}];
	[action SH_addButtonWithTitle:@"Copy URL" withBlock:^(NSInteger theButtonIndex) {
		[[UIPasteboard generalPasteboard] setURL:URL];
	}];
	[action SH_addButtonDestructiveWithTitle:[self.issue isResolved] ? @"Reopen Issue" : @"Close Issue" withBlock:^(NSInteger theButtonIndex) {
		[[CLSAPIClient sharedInstance] setResolved:![self.issue isResolved]
										  forIssue:self.issue];
	}];
	[action SH_addButtonCancelWithTitle:@"Cancel" withBlock:nil];
	[action showInView:self.view];
}

#pragma mark - Private

- (void)_processIncidentSession:(CLSSession *)session {
	if (![session.events count]) {
		return;
	}
	
	self.session = session;
	self.lastEvent = [session lastEvent];	
	self.currentDetailsViewController.session = session;
}

- (void)_setSelectedSection:(NSInteger)segment {
	[self.currentDetailsViewController willMoveToParentViewController:nil];
	[self.currentDetailsViewController.view removeFromSuperview];
	[self.currentDetailsViewController removeFromParentViewController];
	
	NSString *identifier = [self _viewControllerIdentifierForSegment:segment];
	NSAssert(identifier, @"No view controller for chosen segment");
	CLSSessionDetailsAbstractViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
	[self addChildViewController:viewController];
	[self.detailsContainerView addSubview:viewController.view];
	viewController.view.frame = self.detailsContainerView.bounds;
	[viewController didMoveToParentViewController:self];
	self.currentDetailsViewController = viewController;
	if (self.session) {
		viewController.session = self.session;
	}
	[self.segmentedControl setSelectedSegmentIndex:segment];
}

- (NSString *)_viewControllerIdentifierForSegment:(NSInteger)segment {
	switch (segment) {
		case kCLSExceptionSegment:
			return @"IssueException";
		case kCLSThreadsSegment:
			return @"IssueDetailsThreads";
		case kCLSDeviceSegment:
			return @"IssueDeviceDetails";
	}
	return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
		
	// setting up segmented control
	[self.segmentedControl removeAllSegments];
	[self.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"CLSIssueDetailsSegmentDetails", @"Details segment title in issues detail screen")
										  atIndex:kCLSDeviceSegment
										 animated:NO];
	[self.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"CLSIssueDetailsSegmentException", @"Exception segment title in issues detail screen")
										  atIndex:kCLSExceptionSegment
										 animated:NO];
	[self.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"CLSIssueDetailsSegmentThreads", @"Threads segment title in issues detail screen")
										  atIndex:kCLSThreadsSegment
										 animated:NO];
	
	// Wiring signals
	RACSignal *issueDidChangeSignal = [RACObserve(self, issue) filter:^BOOL(CLSIssue *issue) {
		return issue != nil;
	}];
	RACSignal *activeAccountDidChangeSignal = [[CLSAccount activeAccountChangedSignal] filter:^BOOL(id account) {
		return account != nil;
	}];
		
	@weakify(self);
	[[RACSignal
		combineLatest:@[issueDidChangeSignal, activeAccountDidChangeSignal]]
		subscribeNext:^(id x) {
			@strongify(self);
			self.title = [NSString stringWithFormat:@"Issue #%@", self.issue.displayID];
			self.exceptionTypeLabel.text = self.issue.title;
			self.exceptionDescriptionLabel.text = self.issue.subtitle;
			
			if (self.issue.lastSession) {
				[self _processIncidentSession:self.issue.lastSession];
			} else {
				[[[CLSAPIClient sharedInstance] latestIncidentForIssue:self.issue]
					subscribeNext:^(id x) {
						@strongify(self);
						self.title = [NSString stringWithFormat:@"Issue #%@", self.issue.displayID];
						self.exceptionTypeLabel.text = self.issue.title;
						self.exceptionDescriptionLabel.text = self.issue.subtitle;
						
						[[[CLSAPIClient sharedInstance] detailsForIssue:self.issue]
						 subscribeNext:^(CLSSession *session) {
							@strongify(self);
							[self _processIncidentSession:session];
						}];
					}];
			}
		}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self _setSelectedSection:kCLSDeviceSegment];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
	
	self.exceptionDescriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.view.bounds) - CGRectGetMinX(self.exceptionDescriptionLabel.frame) * 2;
	self.exceptionTypeLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.view.bounds) - CGRectGetMinX(self.exceptionTypeLabel.frame) * 2;
}

@end
