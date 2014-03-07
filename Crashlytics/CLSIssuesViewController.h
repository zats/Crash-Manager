//
//  CLSBugsViewController.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/22/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSTableViewController.h"

@class CRMApplication;
@interface CLSIssuesViewController : CLSTableViewController

@property (nonatomic, weak) CRMApplication *application;

@end
