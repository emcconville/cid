//
//  CidException.h
//  cid
//
//  Created by Eric McConville on 7/7/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CidException : NSException
/**
 * @brief Helper class method for easy exception raising.
 * @param format Message, or format-template for vargs
 * @throws CidException
 */
+(void)throwMessage:(NSString *)format, ...;
@end
