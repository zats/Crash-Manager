//
//  CRMPushNotificationSettingTableViewCell.m
//  CrashManager
//
//  Created by Sasha Zats on 3/21/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CRMPushNotificationSettingTableViewCell.h"

@interface CRMPushNotificationSettingTableViewCell ()
@property (nonatomic, weak, readwrite) IBOutlet UISwitch *switchView;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *applicationNameLabel;
@end

@implementation CRMPushNotificationSettingTableViewCell

- (IBAction)_switchViewAction:(id)sender {
    [self.delegate pushNotificationSettingTableViewCell:self
                                   didChangeSwitchValue:self.switchView.isOn];
}

@end
