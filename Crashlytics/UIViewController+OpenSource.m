//
//  UIViewController+OpenSource.m
//  CrashManager
//
//  Created by Sasha Zats on 2/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "UIViewController+OpenSource.h"

#import "CLSConfiguration.h"
#import <PBWebViewController/PBWebViewController.h>
#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>
#import <TUSafariActivity/TUSafariActivity.h>
#import <ARChromeActivity/ARChromeActivity.h>

@implementation UIViewController (OpenSource)

- (void)cls_exposeSource {
    NSAssert([self isViewLoaded], @"Can not instantiate source observation before view is loaded");
    if (![self isViewLoaded]) {
        return;
    }

    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] init];
    // Reactive cocoa creates a dynamic class so we have to preserve the
    // class reference in advance
    Class className = [self class];
    [[[pinchGestureRecognizer.rac_gestureSignal
        filter:^BOOL(UIPinchGestureRecognizer *pinchGestureRecognizer) {
            return pinchGestureRecognizer.state == UIGestureRecognizerStateEnded;
        }]
        filter:^BOOL(UIPinchGestureRecognizer *pinchGestureRecognizer) {
            return pinchGestureRecognizer.scale < 1;
        }]
        subscribeNext:^(id x) {
            // We want to resolve URL as late as possible: configuration might
            // be updated remotely
            NSURL *URL = [[CLSConfiguration sharedInstance] implementationURLForClass:className];
            if (!URL) {
                return;
            }
            
            [self _showWebViewControllerWithURL:URL];
        }];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
}

#pragma mark - Private

- (void)_showWebViewControllerWithURL:(NSURL *)URL {
    PBWebViewController *webViewController = [[PBWebViewController alloc] init];
    webViewController.URL = URL;
	webViewController.applicationActivities = @[ [TUSafariActivity new], [ARChromeActivity new] ];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];

    UIBarButtonItem *closeBarButtonItem = [UIBarButtonItem SH_barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemCancel withBlock:^(UIBarButtonItem *sender) {
        [navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    webViewController.navigationItem.leftBarButtonItem = closeBarButtonItem;
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

@end
