//
//  CLSIssueListCell.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSIssueListCell.h"

@interface CLSIssueListCell ()
@property (weak, nonatomic, readwrite) IBOutlet UILabel *issueNumberLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *issueTitleLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *issueSubtitleLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *issueDetailsLabel;
@property (weak, nonatomic, readwrite) IBOutlet NSLayoutConstraint *baseLayoutConstraint;
@end

@implementation CLSIssueListCell

@end
