//
//  CRMIssuesDataSource.h
//  CrashManager
//
//  Created by Sasha Zats on 3/8/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CRMIssue;
@class CRMIssueListCell;
@interface CRMIssuesDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, weak, readonly) UITableView *tableView;

- (instancetype)initWithTableView:(UITableView *)tableView;

@end


@interface CRMIssuesDataSource (SubclassingHooks)

- (CRMIssue *)issueForIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForIssue:(CRMIssue *)issue;

- (void)configureCell:(CRMIssueListCell *)cell withIssue:(CRMIssue *)issue indexPath:(NSIndexPath *)indexPath;

- (BOOL)isOnlyRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isFirstRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isLastRowAtIndexPath:(NSIndexPath *)indexPath;

@end