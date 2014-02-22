//
//  CLSApplicationsViewController.h
//  Crashlytics
//
//  Created by Sasha Zats on 12/8/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSTableViewController.h"

@class CLSOrganization;
@interface CLSApplicationsViewController : CLSTableViewController

@property (nonatomic, weak) CLSOrganization *organization;

@end
