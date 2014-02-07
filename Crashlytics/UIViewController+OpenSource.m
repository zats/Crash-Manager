//
//  UIViewController+OpenSource.m
//  CrashManager
//
//  Created by Sasha Zats on 2/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "UIViewController+OpenSource.h"

#import "CLSConfiguration.h"

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
        // At this point [self class] would point to the
        // ClassName_RACSelectorSignal instead of ClassName
        NSURL *URL = [[CLSConfiguration sharedInstance] implementationURLForClass:className];
        if (!URL) {
            return;
        }
        
        [[UIApplication sharedApplication] openURL:URL];
    }];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
}

@end
