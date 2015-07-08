//
//  CidApp.h
//  cid
//
//  Created by Eric McConville on 7/5/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CIFeature+Dict.h"
#import "CidSerializer.h"

void version();
void usage();
void help();

@interface CidApp : NSObject {
    NSString * command,
             * inputImagePath,
             * outputPath;
    CIDetector * scanner;
    CIContext * buffer;
    NSMutableDictionary * detectorFeatures, * accuracy;
    NSMutableArray * features;
    OutputFormatType outputFormatType;
    CGRect extent;
}
@property (nonatomic, strong) NSArray * flags;
@property (nonatomic, strong) NSArray * kwargs;
@property (nonatomic, strong) NSURL * inputImage;
/**
 * @brief Iterate over given arguments
 * @param argv List of pointers.
 * @param argc Number of pointers.
 * @return BOOL on success
 */
-(BOOL)parseArguments:(const char **)argv count:(int)argc;
/**
 * @brief Allocate correct Core Image Detector based on command given in parseArguments:count
 * @return BOOL on success
 */
-(BOOL)createScanner;
/**
 * @brief Performs the detection scan over Core Image
 * @return BOOL on success
 */
-(BOOL)scan;
/**
 * @brief Dump serialized features to output (default stdout)
 * @return BOOL on success
 */
-(BOOL)print;
/**
 * @brief Helper method to wrap image extent
 * @return CGRect extent
 */
-(CGRect)extent;
@end
