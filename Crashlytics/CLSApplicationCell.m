//
//  CLSApplicationCell.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/29/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSApplicationCell.h"

@interface CLSApplicationCell ()
@property (strong, nonatomic, readwrite) IBOutlet UIImageView *applicationIconImageView;
@property (strong, nonatomic, readwrite) IBOutlet UILabel *applicationNameLabel;
@property (strong, nonatomic, readwrite) IBOutlet UILabel *applicationBundleIDLabel;
@property (strong, nonatomic, readwrite) IBOutlet UILabel *applicationDetailsLabel;

@property (strong, nonatomic, readwrite) IBOutlet NSLayoutConstraint *baseLayoutConstraint;
@end

@implementation CLSApplicationCell

#pragma mark - Private

- (void)_init {
	self.applicationIconImageView.layer.cornerRadius = 13.0f;
	self.applicationIconImageView.layer.masksToBounds = YES;
	self.applicationIconImageView.layer.borderWidth = 1.0f;
	self.applicationIconImageView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.1].CGColor;
}

#pragma mark - UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (!self) {
		return nil;
	}
	[self _init];
	return self;
}

#pragma mark - NSObject

- (void)awakeFromNib {
	[super awakeFromNib];
	[self _init];
}

@end
