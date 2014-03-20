//
//  CRMIssuesDefaultDataSource.m
//  CrashManager
//
//  Created by Sasha Zats on 3/8/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMIssuesDefaultDataSource.h"

#import "CRMApplication.h"
#import "CRMFilter.h"
#import "CRMIssue.h"

@interface CRMIssuesDefaultDataSource () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong, readwrite) CRMApplication *application;
@property (nonatomic, strong, readwrite) RACSignal *filterChangedSignal;


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSMutableIndexSet *insertedSections;
@property (nonatomic, strong) NSMutableIndexSet *deletedSections;
@property (nonatomic, strong) NSMutableSet *insertedRows;
@property (nonatomic, strong) NSMutableSet *deletedRows;
@property (nonatomic, strong) NSMutableSet *updatedRows;

@end

@implementation CRMIssuesDefaultDataSource

#pragma mark - Lifecycle

- (instancetype)initWithTableView:(UITableView *)tableView application:(CRMApplication *)applicaton filterChangedSignal:(RACSignal *)filterChangedSignal {
    self = [super initWithTableView:tableView];
    if (!self) {
        return nil;
    }
    
    self.application = applicaton;
    self.filterChangedSignal = filterChangedSignal;
    
    NSParameterAssert(applicaton);
    NSParameterAssert(filterChangedSignal);

    [self _setup];
    [self _setupReactive];

    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView {
    return [self initWithTableView:tableView
                       application:nil
               filterChangedSignal:nil];
}

- (void)dealloc {
    self.fetchedResultsController.delegate = nil;
}

#pragma mark - Private

- (void)_setup {
    self.insertedSections = [NSMutableIndexSet indexSet];
    self.deletedSections = [NSMutableIndexSet indexSet];
    
    self.insertedRows = [NSMutableSet set];
    self.deletedRows = [NSMutableSet set];
    self.updatedRows = [NSMutableSet set];
}

- (void)_setupReactive {
    @weakify(self);
    RAC(self, fetchedResultsController) = [RACObserve(self, application)
        map:^id(CRMApplication *application) {
            NSFetchedResultsController *fetchedResultsController = [CRMIssue MR_fetchAllGroupedBy:nil
                                                                                    withPredicate:[application.filter predicate]
                                                                                         sortedBy:nil
                                                                                        ascending:YES];
            NSArray *sortDescriptors = @[
                // Impact Level
                [NSSortDescriptor sortDescriptorWithKey:CRMIssueAttributes.impactLevel
                                           ascending:NO],
                // Number of crashes
                [NSSortDescriptor sortDescriptorWithKey:CRMIssueAttributes.crashesCount
                                           ascending:NO],
                // Number of users affected by the crash
                [NSSortDescriptor sortDescriptorWithKey:CRMIssueAttributes.devicesAffected
                                           ascending:NO],
                // Unresolved issues should come before resovled
                // Issues resolved today yesterday should go before issues resolved yesterday
                [NSSortDescriptor sortDescriptorWithKey:CRMIssueAttributes.resolvedAt
                                           ascending:YES],
                // As a final meause, we sort by the title
                    [NSSortDescriptor sortDescriptorWithKey:CRMIssueAttributes.title
                                                  ascending:NO
                                                   selector:@selector(localizedStandardCompare:)]
            ];
            fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors;
            return fetchedResultsController;
        }];
    
    // Observe filter changes
    [RACObserve(self, filterChangedSignal) subscribeNext:^(RACSignal *signal) {
        [signal subscribeNext:^(id x) {
            @strongify(self);
            self.fetchedResultsController.fetchRequest.predicate = [self.application.filter predicate];
        }];
    }];

    [[RACSignal combineLatest:@[ RACObserve(self, fetchedResultsController.fetchRequest.predicate), RACObserve(self, fetchedResultsController.fetchRequest.sortDescriptors) ]] subscribeNext:^(id x) {
        @strongify(self);
        self.fetchedResultsController.delegate = self;

        NSError *error = nil;
        ZAssert([self.fetchedResultsController performFetch:&error], @"Failed to fetch issues for application %@\n%@", self.application.name, error);
        [self.tableView reloadData];
    }];
    
    RACSignal *isPausedSignal = RACObserve(self, isPaused);
    [[isPausedSignal filter:^BOOL(id value) {
        return ![value boolValue];
    }] subscribeNext:^(id x) {
        @strongify(self);
        NSError *error = nil;
        ZAssert([self.fetchedResultsController performFetch:&error], @"Failed to fetch issues with fetch request %@ %@", self.fetchedResultsController.fetchRequest, error);
        [self.tableView reloadData];
    }];
    
    RAC(self, fetchedResultsController.delegate) = [isPausedSignal
        map:^id(NSNumber *isPausedValue) {
            @strongify(self);
            return [isPausedValue boolValue] ? self : nil;
        }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

#pragma mark - CRMIssuesDataSource (SubclassingHooks)

- (CRMIssue *)issueForIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForIssue:(CRMIssue *)issue {
    return [self.fetchedResultsController indexPathForObject:issue];
}

- (BOOL)isOnlyRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= [self.fetchedResultsController.sections count]) {
        return NO;
    }
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[indexPath.section];
    return sectionInfo.numberOfObjects == 1 && indexPath.row == 0;
}

- (BOOL)isFirstRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0;
}

- (BOOL)isLastRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= [self.fetchedResultsController.sections count]) {
        return NO;
    }
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[indexPath.section];
    return indexPath.row == sectionInfo.numberOfObjects - 1;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [self.deletedSections addIndex:sectionIndex];
            break;
            
        case NSFetchedResultsChangeInsert:
            [self.insertedSections addIndex:sectionIndex];
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeDelete:
            if (![self.deletedSections containsIndex:indexPath.section]) {
                [self.deletedRows addObject:indexPath];
            }
            break;

        case NSFetchedResultsChangeInsert:
            if (![self.insertedSections containsIndex:newIndexPath.section]) {
                [self.insertedRows addObject:newIndexPath];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            if (![self.deletedSections containsIndex:indexPath.section]) {
                [self.deletedRows addObject:indexPath];
            }
            if (![self.insertedSections containsIndex:newIndexPath.section]) {
                [self.insertedRows addObject:newIndexPath];
            }
            break;
            
        case NSFetchedResultsChangeUpdate: {
            [self.updatedRows addObject:indexPath];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
    
    [self.tableView insertSections:self.insertedSections
                  withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView deleteSections:self.deletedSections
                  withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView insertRowsAtIndexPaths:[self.insertedRows allObjects]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView deleteRowsAtIndexPaths:[self.deletedRows allObjects]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadRowsAtIndexPaths:[self.updatedRows allObjects]
                          withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
    
    [self.insertedSections removeAllIndexes];
    [self.deletedSections removeAllIndexes];
    [self.insertedRows removeAllObjects];
    [self.updatedRows removeAllObjects];
    [self.deletedRows removeAllObjects];
}

@end
