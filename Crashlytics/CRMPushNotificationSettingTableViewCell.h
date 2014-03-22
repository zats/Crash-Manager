//
//  CRMPushNotificationSettingTableViewCell.h
//  CrashManager
//
//  Created by Sasha Zats on 3/21/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CRMPushNotificationSettingTableViewCellDelegate;
@interface CRMPushNotificationSettingTableViewCell : UITableViewCell

@property (nonatomic, weak, readonly) UISwitch *switchView;
@property (nonatomic, weak, readonly) UILabel *applicationNameLabel;
@property (nonatomic, weak) id<CRMPushNotificationSettingTableViewCellDelegate> delegate;

@end

@protocol CRMPushNotificationSettingTableViewCellDelegate <NSObject>

- (void)pushNotificationSettingTableViewCell:(CRMPushNotificationSettingTableViewCell *)cell
                        didChangeSwitchValue:(BOOL)newValue;

@end
