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

@implementation UIViewController (OpenSource)

- (void)cls_exposeSource {
    NSAssert([self isViewLoaded], @"Can not instantiate source observation before view is loaded");
    if (![self isViewLoaded]) {
        return;
    }
    
    // TODO: expose children's pinch gesture recognizers: this way we can pinch
    // on nested child view controllers and get the right controller instead of
    // the outer one    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] init];
    Class className = [self class];
    [pinchGestureRecognizer.rac_gestureSignal subscribeNext:^(UIPinchGestureRecognizer *pinchGestureRecognizer) {
        if (pinchGestureRecognizer.state != UIGestureRecognizerStateEnded) {
            return;
        }
        
        if (pinchGestureRecognizer.scale >= 1) {
            return;
        }
        
        // At this point [self class] would point to the
        // ClassName_RACSelectorSignal instead of ClassName
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
