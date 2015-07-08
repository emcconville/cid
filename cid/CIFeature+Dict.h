//
//  CIFeature+Dict.h
//  cid
//
//  Created by Eric McConville on 7/6/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CIFeature (Dict)
/**
 * @brief Iterate, and normalize, all sub-class CI Features into a standard dict.
 * @param options User defined options.
 * @return Normalized feature attributes.
 */
-(NSDictionary *)dict:(NSDictionary *)options;
@end
