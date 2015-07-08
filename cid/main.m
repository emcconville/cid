//
//  main.m
//  cid
//
//  Created by Eric McConville on 7/5/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CidApp.h"
#import "CidException.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        @try {
            CidApp * app = [[CidApp alloc] init];
            if (argc < 2) {
                usage();
                [CidException throwMessage:@"Missing command\n"];
            }
            if ([app parseArguments:&argv[1] count:argc-1]) {
                if ([app scan]) {
                    [app print];
                }
            }
        }
        @catch (NSException *err) {
            // Re-throw to Xcode / lldb
            // @throw err;
            [[err reason] writeToFile:@"/dev/stderr"
                           atomically:NO
                             encoding:NSUTF8StringEncoding
                                error:nil];
        }
    }
    return 0;
}
