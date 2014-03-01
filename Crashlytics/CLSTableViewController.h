//
//  CLSTableViewController.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSFetchedResultsController;
@interface CLSTableViewController : UITableViewController

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (NSInteger)displaySectionForCoreDataSection:(NSInteger)section;
- (NSInteger)coreDataSectionForDisplaySection:(NSInteger)section;
- (NSIndexPath *)displayIndexPathForCoreDataIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)coreDataIndexPathForDisplayIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isFirstRowInSectionAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastRowInSectionAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isOnlyRowInSectionAtIndexPath:(NSIndexPath *)indexPath;

@end
