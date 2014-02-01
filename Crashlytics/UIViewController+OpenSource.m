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
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] init];
    @weakify(self);
    [pinchGestureRecognizer.rac_gestureSignal subscribeNext:^(id x) {
        @strongify(self);

        NSURL *URL = [[CLSConfiguration sharedInstance] implementationURLForClass:[self class]];
        if (!URL) {
            return;
        }
        
        [[UIApplication sharedApplication] openURL:URL];
    }];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
}

@end
