//
//  CRMIssueCell.h
//  Crash Manager
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRMIssueCell : UITableViewCell
@property (weak, nonatomic, readonly) UILabel *issueNumberLabel;
@property (weak, nonatomic, readonly) UILabel *issueTitleLabel;
@property (weak, nonatomic, readonly) UILabel *issueSubtitleLabel;
@property (weak, nonatomic, readonly) UILabel *issueDetailsLabel;
@property (weak, nonatomic, readonly) UIImageView *impactLevelImageView;

@property (weak, nonatomic, readonly) NSLayoutConstraint *baseLayoutConstraint;
@end
