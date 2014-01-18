//
//  CLSFiltersViewController.h
//  Crashlytics
//
//  Created by Sasha Zats on 12/30/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLSApplication;
@protocol CLSFilterViewControllerDelegate;
@interface CLSFiltersViewController : UITableViewController

@property (nonatomic, weak) id<CLSFilterViewControllerDelegate> delegate;
@property (nonatomic, weak) CLSApplication *application;
@end

@protocol CLSFilterViewControllerDelegate <NSObject>
	
@optional
- (void)filterViewControllerDidFinish:(CLSFiltersViewController *)filterViewController;
	
@end