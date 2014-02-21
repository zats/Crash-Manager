//
//  CLSIssueImpactLevelView.m
//  CrashManager
//
//  Created by Sasha Zats on 2/21/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CLSIssueImpactLevelView.h"

@interface CLSIssueImpactLevelView ()

@end

@implementation CLSIssueImpactLevelView

#pragma mark - Public

- (void)setImpactLevel:(NSUInteger)impactLevel {
	if (_impactLevel == impactLevel) {
		return;
	}
	_impactLevel = impactLevel;
	[self setNeedsDisplay];
}

#pragma mark - UIView

- (void)tintColorDidChange {
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	// total of 5 levels
	
}

@end
