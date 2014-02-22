//
//  CLSSessionDetailsAbstractViewController.h
//  CrashManager
//
//  Created by Sasha Zats on 2/8/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLSSession;
@interface CLSSessionDetailsAbstractViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak, readonly) UITableView *tableView;

@property (nonatomic, weak) CLSSession *session;
@property (nonatomic, strong, readonly) RACSignal *sessionChangedSignal;

@end
