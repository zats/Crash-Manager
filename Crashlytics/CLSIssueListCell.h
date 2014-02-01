//
//  CLSIssueListCell.h
//  Crashlytics
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLSIssueListCell : UITableViewCell
@property (strong, nonatomic, readonly) UILabel *issueNumberLabel;
@property (strong, nonatomic, readonly) UILabel *issueTitleLabel;
@property (strong, nonatomic, readonly) UILabel *issueSubtitleLabel;
@property (strong, nonatomic, readonly) UILabel *issueDetailsLabel;

@property (strong, nonatomic, readonly) NSLayoutConstraint *baseLayoutConstraint;
@end
