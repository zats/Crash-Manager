//
//  NSURLRequest+CRMLogging.m
//  CrashManager
//
//  Created by Sasha Zats on 2/1/14.
//  Copyright (c) 2014 Sasha Zats. All rights reserved.
//

#import "NSURLRequest+CRMLogging.h"

@implementation NSURLRequest (CRMLogging)

- (NSString *)cls_cURLCommand {
    NSMutableString *command = [NSMutableString stringWithString:@"curl"];
    
    [command appendFormat:@" -X %@", [self HTTPMethod]];
    
    if ([[self HTTPBody] length] > 0) {
        NSMutableString *HTTPBodyString = [[NSMutableString alloc] initWithData:[self HTTPBody] encoding:NSUTF8StringEncoding];
        [HTTPBodyString replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [HTTPBodyString replaceOccurrencesOfString:@"`" withString:@"\\`" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [HTTPBodyString replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [HTTPBodyString replaceOccurrencesOfString:@"$" withString:@"\\$" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [command appendFormat:@" -d \"%@\"", HTTPBodyString];
    }
    
    NSString *acceptEncodingHeader = [[self allHTTPHeaderFields] valueForKey:@"Accept-Encoding"];
    if ([acceptEncodingHeader rangeOfString:@"gzip"].location != NSNotFound) {
        [command appendString:@" --compressed"];
    }
    
    if ([self URL]) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[self URL]];
        for (NSHTTPCookie *cookie in cookies) {
            [command appendFormat:@" --cookie \"%@=%@\"", [cookie name], [cookie value]];
        }
    }
    
    for (id field in [self allHTTPHeaderFields]) {
        [command appendFormat:@" -H %@", [NSString stringWithFormat:@"'%@: %@'", field, [[self valueForHTTPHeaderField:field] stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"]]];
    }
    
    [command appendFormat:@" \"%@\"", [[self URL] absoluteString]];
    
    return [command copy];
}

@end
