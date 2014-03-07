//
//  CLSApplicationsViewController.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/8/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSTableViewController.h"

@class CRMOrganization;
@interface CLSApplicationsViewController : CLSTableViewController

@property (nonatomic, weak) CRMOrganization *organization;

@end
