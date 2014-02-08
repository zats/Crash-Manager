//
//  CLSApplicationCell.h
//  Crashlytics
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLSApplicationCell : UITableViewCell

@property (weak, nonatomic, readonly) UIImageView *applicationIconImageView;
@property (weak, nonatomic, readonly) UILabel *applicationNameLabel;
@property (weak, nonatomic, readonly) UILabel *applicationBundleIDLabel;
@property (weak, nonatomic, readonly) UILabel *applicationDetailsLabel;

@property (strong, nonatomic, readonly) IBOutlet NSLayoutConstraint *baseLayoutConstraint;

@end
