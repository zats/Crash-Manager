//
//  CLSIssueDetailsViewController.h
//  Crashlytics
//
//  Created by Sasha Zats on 12/23/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSViewController.h"

@class CLSIssue;
@interface CLSIssueDetailsViewController : CLSViewController

@property (nonatomic, weak) CLSIssue *issue;



@end
