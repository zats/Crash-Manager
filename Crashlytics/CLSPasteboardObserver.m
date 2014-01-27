//
//  CLSPasteboardObserver.m
//  Crashlytics
//
//  Created by Sasha Zats on 1/4/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CLSPasteboardObserver.h"

#import "CLSOrganization.h"
#import "CLSApplication.h"
#import "CLSIssue.h"
#import "CLSApplicationsTableViewController.h"
#import "CLSIssuesTableViewController.h"
#import "CLSIssueDetailsViewController.h"
#import <Crashlytics/Crashlytics.h>
#import <SHAlertViewBlocks/SHAlertViewBlocks.h>

@interface CLSPasteboardObserver ()
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, copy) NSString *lastNavigatedURLString;
@end

@implementation CLSPasteboardObserver

+ (instancetype)sharedInstance {
	static CLSPasteboardObserver *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[CLSPasteboardObserver alloc] init];
	});
	return instance;
}

#pragma mark - Public

- (void)startObservingParsteboardWithNavigationController:(UINavigationController *)navigationController {
	[self stopObservingPasteboard];
	
	// listen application did become active to check if pasteboard contains
	// an issue URL after coming back to the app
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_applicationDidBecomeActiveNotificationHandler:)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];

	// listen to pasteboard updates,
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_pasteboardChangedNotificationHandler:)
												 name:UIPasteboardChangedNotification
											   object:[UIPasteboard generalPasteboard]];
	self.navigationController = navigationController;
	
	// finally we immidiately check the pasteboard in case it already contained
	// something interesting
	[self _checkPasteboardContents];
}

- (void)stopObservingPasteboard {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.navigationController = nil;
}

#pragma mark - Actions

- (void)_pasteboardChangedNotificationHandler:(NSNotification *)notification {
	[self _checkPasteboardContents];
}

- (void)_applicationDidBecomeActiveNotificationHandler:(id)sender {
	[self _checkPasteboardContents];
}

#pragma mark - Private

- (void)_checkPasteboardContents {
	NSString *urlString = [[[UIPasteboard generalPasteboard] URL] absoluteString];
	if (!urlString) {
		urlString = [[UIPasteboard generalPasteboard] string];
	}
	if (![urlString length]) {
		return;
	}
	
	// try to decode URL string
	urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	// we ignore url string if we already nagged user about it
	if ([urlString isEqualToString:self.lastNavigatedURLString]) {
		return;
	}

	NSRange urlStringRange = NSMakeRange(0, [urlString length]);
	NSArray *matchDescriptors = [[NSUserDefaults standardUserDefaults] objectForKey:@"CrashlyticsLinksMatching"];
	NSString *organizationAlias = nil, *bundleID = nil, *issueID = nil;
	for (NSDictionary *matchDescriptor in matchDescriptors) {
		NSString *regexPattern = matchDescriptor[@"regex"];
		NSError *error = nil;
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern//?/[NSRegularExpression escapedTemplateForString:regexPattern]
																			   options:NSRegularExpressionCaseInsensitive
																				 error:&error];
		if (!regex) {
			CLSNSLog(@"Failed to compile a regex from pattern: %@", regexPattern);
			continue;
		}
		
		NSArray *matches = [regex matchesInString:urlString
										  options:0
											range:urlStringRange];
		NSTextCheckingResult *textCheckingResult = [matches firstObject];
		if (!textCheckingResult) {
			continue;
		}
		if (!textCheckingResult.numberOfRanges) {
			continue;
		}
		NSDictionary *expectedMatches = matchDescriptor[@"matches"];
		
		// Organization Alias
		NSInteger organizationMatchIndex = [expectedMatches[@"organization"] integerValue];
		if (textCheckingResult.numberOfRanges <= organizationMatchIndex) {
			continue;
		}
		NSRange organizationRange = [textCheckingResult rangeAtIndex:organizationMatchIndex];
		if (!NSIntersectionRange(urlStringRange, organizationRange).length) {
			continue;
		}
		organizationAlias = [urlString substringWithRange:organizationRange];
	
		// Bundle ID
		NSInteger bundleIDMatchIndex = [expectedMatches[@"bundleID"] integerValue];
		if (textCheckingResult.numberOfRanges <= bundleIDMatchIndex) {
			continue;
		}
		NSRange bundleIDRange = [textCheckingResult rangeAtIndex:bundleIDMatchIndex];
		if (!NSIntersectionRange(urlStringRange, bundleIDRange).length) {
			continue;
		}
		bundleID = [urlString substringWithRange:bundleIDRange];

		// Issue ID
		NSInteger issueIDMatchIndex = [expectedMatches[@"issueID"] integerValue];
		if (textCheckingResult.numberOfRanges <= issueIDMatchIndex) {
			continue;
		}
		NSRange issueIDRange = [textCheckingResult rangeAtIndex:issueIDMatchIndex];
		if (!NSIntersectionRange(urlStringRange, issueIDRange).length) {
			continue;
		}
		issueID = [urlString substringWithRange:issueIDRange];
		
		if ([self _isValidIssueWithIssueID:issueID
								  bundleID:bundleID
						 organizationAlias:organizationAlias]) {
			break;
		}
	}
	
	if (![self _isValidIssueWithIssueID:issueID
							   bundleID:bundleID
					  organizationAlias:organizationAlias]) {
		// failed to detect all the components
		return;
	}
	
	self.lastNavigatedURLString = urlString;
	
	UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
	if ([rootViewController isKindOfClass:[UINavigationController class]]) {
		UIViewController *currentlyVisibleViewController = [((UINavigationController *)rootViewController).viewControllers lastObject];
		if ([currentlyVisibleViewController isKindOfClass:[CLSIssueDetailsViewController class]]) {
			BOOL showCurrentIssueID = [((CLSIssueDetailsViewController *)currentlyVisibleViewController).issue.issueID isEqualToString:issueID];
			if (showCurrentIssueID) {
				// no need to prompt user if we're already looking at the issue details
				return;
			}
		}
	}
	
    
    
    
    
 
    
    
	NSString *message = NSLocalizedString(@"CLSPasteboardObserverURLDetectedMessage", nil);
	message = [message stringByAppendingFormat:NSLocalizedString(@"CLSPasteboardObserverURLDetectedMessageOrganization", nil), organizationAlias];
	message = [message stringByAppendingFormat:NSLocalizedString(@"CLSPasteboardObserverURLDetectedMessageApp", nil), bundleID];
	message = [message stringByAppendingFormat:NSLocalizedString(@"CLSPasteboardObserverURLDetectedMessageIssue", nil), issueID];
	
	UIAlertView *alert = [UIAlertView SH_alertViewWithTitle:NSLocalizedString(@"CLSPasteboardObserverURLDetectedMessageTitle", nil)
												withMessage:message];
	[alert SH_addButtonWithTitle:NSLocalizedString(@"CLSPasteboardObserverURLDetectedMessageCancelTitle", nil)
					   withBlock:nil];
	[alert SH_addButtonCancelWithTitle:NSLocalizedString(@"CLSPasteboardObserverURLDetectedMessageNavigateTitle", nil) withBlock:^(NSInteger theButtonIndex) {
		id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
		[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"navigation"
															  action:@"clipboard_issue_navigation"
															   label:[NSString stringWithFormat:@"%@/%@/%@", organizationAlias, bundleID, issueID]
															   value:nil] build]];
		
		CLSOrganization *organization = [CLSOrganization MR_findFirstByAttribute:CLSOrganizationAttributes.alias
																	   withValue:organizationAlias];
		
		CLSApplication *application = [CLSApplication MR_findFirstByAttribute:CLSApplicationAttributes.bundleID
																	withValue:bundleID];

		CLSIssue *issue = [CLSIssue MR_findFirstByAttribute:CLSIssueAttributes.issueID
										 withValue:issueID];
		
		
		if (!issue) {
			issue = [CLSIssue MR_createEntity];
			issue.issueID = issueID;
			issue.application = application;
			[issue.managedObjectContext MR_saveToPersistentStoreAndWait];
		}

		UIStoryboard *storyboard = self.navigationController.storyboard;
		
		UIViewController *organizationsViewController = [self.navigationController.viewControllers firstObject];

		CLSApplicationsTableViewController *appViewController = [storyboard instantiateViewControllerWithIdentifier:@"applications"];
		appViewController.organization = organization;
		
		CLSIssuesTableViewController *issuesViewController = [storyboard instantiateViewControllerWithIdentifier:@"issues"];
		issuesViewController.application = application;
		
		CLSIssueDetailsViewController *issueDetailsViewController = [storyboard instantiateViewControllerWithIdentifier:@"issueDetails"];
		issueDetailsViewController.issue = issue;
		
		// Dismiss any modally presented view controller if any
		if (self.navigationController.presentedViewController) {
			[self.navigationController.presentedViewController dismissViewControllerAnimated:NO
																				  completion:nil];
		}
		[self.navigationController setViewControllers:@[ organizationsViewController, appViewController, issuesViewController, issueDetailsViewController ]
											 animated:YES];
		
	}];
	[alert show];
}

// TODO: add actual validation
- (BOOL)_isValidIssueWithIssueID:issueID
						bundleID:bundleID
			   organizationAlias:organizationAlias {
	if (![issueID length] ||
		![bundleID length] ||
		![organizationAlias length]) {
		return NO;
	}
	
	CLSIssue *issue = [CLSIssue MR_findFirstByAttribute:CLSIssueAttributes.issueID
											  withValue:issueID];
	if (!issue) {
		issue = [CLSIssue MR_createEntity];
		issue.issueID = issueID;
	}

	CLSApplication *application = [CLSApplication MR_findFirstByAttribute:CLSApplicationAttributes.bundleID
																	withValue:bundleID];
		
	if (!issue.application) {
		issue.application = application;
		[issue.managedObjectContext MR_saveToPersistentStoreAndWait];
	}

	return ([issue.application.applicationID length] &&
			[issue.application.organization.organizationID length]);
}

#pragma mark - NSObject

- (instancetype)init {
	self = [super init];
	if (!self) {
		return nil;
	}

	return self;
}



@end
