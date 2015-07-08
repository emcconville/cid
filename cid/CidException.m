//
//  CidException.m
//  cid
//
//  Created by Eric McConville on 7/7/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import "CidException.h"

@implementation CidException
+(void)throwMessage:(NSString *)format, ...
{
    NSString * message;
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    CidException * err = [[self alloc] initWithName:@"cid error"
                                             reason:message
                                           userInfo:nil];
    [err raise];
}
@end
