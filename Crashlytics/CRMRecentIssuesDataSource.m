//
//  CRMRecentIssuesDataSource.m
//  CrashManager
//
//  Created by Sasha Zats on 3/8/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMRecentIssuesDataSource.h"

#import "CRMIssue.h"

@interface CRMRecentIssuesDataSource ()

@end

@implementation CRMRecentIssuesDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super initWithTableView:tableView];
    if (!self) {
        return nil;
    }
    
    RACSignal *issuesChangedSignal = [self rac_valuesAndChangesForKeyPath:@keypath(self, issues)
                                                                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                                                 observer:self];
    @weakify(self);
    [issuesChangedSignal subscribeNext:^(id x) {
       @strongify(self);
        // TODO: diff arrays to find what was inserted / deleted / moved etc
        [self.tableView reloadData];
    }];
    
    return self;
}

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
    NSString *issueIdetnifier = self.issues[indexPath.row];
    CRMIssue *issue = [CRMIssue MR_findFirstByAttribute:CRMIssueAttributes.issueID
                                              withValue:issueIdetnifier];
    return issue;
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
