//
//  NSURLRequest+CRMLogging.h
//  CrashManager
//
//  Created by Sasha Zats on 2/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (CRMLogging)

/**
 @see https://github.com/mattt/FormatterKit/blame/master/FormatterKit/TTTURLRequestFormatter.m#L45
 
 @return curl-style description for the receiver.
 */
- (NSString *)cls_cURLCommand;


@end
