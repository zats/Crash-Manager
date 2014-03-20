//
//  CRMIssueCell.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMIssueCell.h"

@interface CRMIssueCell ()
@property (weak, nonatomic, readwrite) IBOutlet UILabel *issueNumberLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *issueTitleLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *issueSubtitleLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *issueDetailsLabel;
@property (weak, nonatomic, readwrite) IBOutlet UIImageView *impactLevelImageView;
@property (weak, nonatomic, readwrite) IBOutlet NSLayoutConstraint *baseLayoutConstraint;
@end

@implementation CRMIssueCell

@end
