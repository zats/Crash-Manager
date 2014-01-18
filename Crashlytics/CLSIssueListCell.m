//
//  CLSIssueListCell.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSIssueListCell.h"

@interface CLSIssueListCell ()
@property (strong, nonatomic, readwrite) IBOutlet UILabel *issueNumberLabel;
@property (strong, nonatomic, readwrite) IBOutlet UILabel *issueTitleLabel;
@property (strong, nonatomic, readwrite) IBOutlet UILabel *issueSubtitleLabel;
@property (strong, nonatomic, readwrite) IBOutlet UILabel *issueDetailsLabel;
@property (strong, nonatomic, readwrite) IBOutlet NSLayoutConstraint *baseLayoutConstraint;
@end

@implementation CLSIssueListCell

@end
