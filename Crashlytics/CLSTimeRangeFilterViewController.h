//
//  CLSTimeRangeFilterViewController.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/31/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLSFilter;
@interface CLSTimeRangeFilterViewController : UITableViewController

@property (nonatomic, weak) CLSFilter *filter;

@end
