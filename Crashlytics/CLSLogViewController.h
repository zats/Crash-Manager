//
//  CLSLogViewController.h
//  Crashlytics
//
//  Created by Sasha Zats on 1/3/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLSSession;
@interface CLSLogViewController : UIViewController

@property (nonatomic, weak) CLSSession *session;

@end
