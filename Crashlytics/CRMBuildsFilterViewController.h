//
//  CRMBuildsFilterViewController.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/21/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMTableViewController.h"

@class CRMFilter;
@interface CRMBuildsFilterViewController : CRMTableViewController

@property (nonatomic, weak) CRMFilter *filter;

@end

