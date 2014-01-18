//
//  CLSApplicationCell.h
//  Crashlytics
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLSApplicationCell : UITableViewCell

@property (strong, nonatomic, readonly) UIImageView *applicationIconImageView;
@property (strong, nonatomic, readonly) UILabel *applicationNameLabel;
@property (strong, nonatomic, readonly) UILabel *applicationBundleIDLabel;
@property (strong, nonatomic, readonly) UILabel *applicationDetailsLabel;

@property (strong, nonatomic, readonly) IBOutlet NSLayoutConstraint *baseLayoutConstraint;

@end
