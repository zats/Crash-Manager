//
//  CRMLogViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 1/3/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMLogViewController.h"

#import "CRMIncident.h"
#import "CRMIncident_Session+Crashlytics.h"
#import <SHUIKitBlocks/SHUIKitBlocks.h>

@interface CRMLogViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end

@implementation CRMLogViewController

#pragma mark - Actinos

- (IBAction)_actionsBarButtonItemHandler:(id)sender {
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[ self.textView.attributedText ]
																						 applicationActivities:nil];
	[self presentViewController:activityViewController
					   animated:YES
					 completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	@weakify(self);
	[[RACObserve(self, session) filter:^BOOL(id value) {
		return value != nil;
	}] subscribeNext:^(CRMSession *session) {
		@strongify(self);
		self.textView.text = [session lastEvent].log.content;
	}];
}


@end
