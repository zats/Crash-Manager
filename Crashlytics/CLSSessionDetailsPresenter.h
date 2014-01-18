//
//  CLSSessionDetailsPresenter.h
//  Crashlytics
//
//  Created by Sasha Zats on 12/25/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLSSession;
@protocol CLSSessionDetailsPresenter <NSObject>

@property (nonatomic, strong) CLSSession *session;

@end
