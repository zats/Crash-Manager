//
//  CLSBugsViewController.h
//  Crashlytics
//
//  Created by Sasha Zats on 12/22/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSTableViewController.h"

@class CLSApplication;
@interface CLSIssuesTableViewController : UITableViewController

@property (nonatomic, weak) CLSApplication *application;

@end
