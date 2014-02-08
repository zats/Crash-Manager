//
//  CLSLogViewController.m
//  Crashlytics
//
//  Created by Sasha Zats on 1/3/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CLSLogViewController.h"

#import "CLSIncident.h"
#import "CLSIncident_Session+Crashlytics.h"
#import <SHUIKitBlocks/SHUIKitBlocks.h>

@interface CLSLogViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end

@implementation CLSLogViewController

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
	}] subscribeNext:^(CLSSession *session) {
		@strongify(self);
		self.textView.text = [session lastEvent].log.content;
	}];
}


@end
