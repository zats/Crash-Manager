//
//  CRMLogViewController.h
//  Crash Manager
//
//  Created by Sasha Zats on 1/3/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "CLSViewController.h"

@class CRMSession;
@interface CRMLogViewController : CLSViewController

@property (nonatomic, weak) CRMSession *session;

@end
