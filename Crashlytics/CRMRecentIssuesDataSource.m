//
//  CRMRecentIssuesDataSource.m
//  CrashManager
//
//  Created by Sasha Zats on 3/8/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMRecentIssuesDataSource.h"

@interface CRMRecentIssuesDataSource ()

@end

@implementation CRMRecentIssuesDataSource

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section > 0) {
        return 0;
    }
    return [self.issues count];
}

#pragma mark - CRMIssuesDataSource (SubclassingHooks)

- (CRMIssue *)issueForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 || indexPath.row >= [self.issues count]) {
        return nil;
    }
    return self.issues[indexPath.row];
}

- (NSIndexPath *)indexPathForIssue:(CRMIssue *)issue {
    NSUInteger indexOfIssue = [self.issues indexOfObjectIdenticalTo:issue];
    if (indexOfIssue == NSNotFound) {
        return nil;
    }
    return [NSIndexPath indexPathForRow:indexOfIssue
                              inSection:0];
}

- (BOOL)isOnlyRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.issues count] == 1 && indexPath.row == 0;
}

- (BOOL)isFirstRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0;
}

- (BOOL)isLastRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == [self.issues count] - 1;
}

@end
