//
//  CidApp.m
//  cid
//
//  Created by Eric McConville on 7/5/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import "CidApp.h"
#import "CidException.h"


#pragma mark - Application Info

#define xstr(s) str(s)
#define str(s) #s

#ifndef CID_VERSION
#define CID_VERSION "1.dev"
#endif

#ifndef CID_RELEASE_DATE
#define CID_RELEASE_DATE "2015-07-05"
#endif

#ifndef CID_RELEASE_URL
#define CID_RELEASE_URL "https://github.com/emcconville/cid"
#endif

static const char * _version = "Version: cid %s %s %s\n"
"Copyright: Copyright (C) 2015 emcconville\n"
"\n";

void version() {
    fprintf(stdout, _version,
            xstr(CID_VERSION),
            xstr(CID_RELEASE_DATE),
            xstr(CID_RELEASE_URL));
}

static const char * _usage = ""
"Usage: cid <command> [arguments, ...] <file>\n"
"       cid help\n"
"\n";

void usage() {
    version();
    fprintf(stdout, "%s", _usage);
};

static const char * _help = "\n"
"Commands\n"
"--------\n"
"\n"
"face         Detect faces in an image.\n"
"help, -h     Display this help message.\n"
"rectangle    Detect rectangles in an image.\n"
"qr           Detect & decode QR codes in an image.\n"
"version, -v  Display version info.\n"
"\n"
"Argument Flags\n"
"--------------\n"
"\n"
"-blink       Include closed-eye feature in `face' command.\n"
"-low         Set low accuracy for faster detection.\n"
"-smile       Include smile detection in `face' command.\n"
"-yAxis       Invert Y-axis coordinate system making the\n"
"             origin of an image top-left.\n"
"\n"
"Argument Keywords\n"
"-----------------\n"
"\n"
"-aspectRatio <F>  Set rectangle detector aspect ration.\n"
"                  Where <F> is width / height.\n"
"-focalLength <F>  Set rectangle detector focal length.\n"
"                  Expecting value between -1.0 and 1.0.\n"
"-format <type>    Set output sterilization format.\n"
"                  Type can be one of the following:\n"
"                  - JSON       (default)\n"
"                  - PLIST      (xml style)\n"
"                  - PLIST_BIN  (binary style)\n"
"                  - SVG\n"
"-orientation <I>  Define image orientation. If omitted, orientation\n"
"                  will be extracted by image meta-data.\n"
"                  Expecting integer value between 1 & 8\n"
"-o <path>         Write features to file path. If omitted, features\n"
"                  will be written to stdout.\n"
"-threshold <F>    Set minimum dimension size of feature detection.\n"
"                  Expecting value between 0.0 and 1.0.\n"
"\n"
;

void help() {
    usage(); // Calls version
    fprintf(stdout, "%s", _help);
}


@implementation CidApp
@synthesize flags = _flags;
@synthesize kwargs = _kwargs;
@synthesize inputImage = _inputImage;
-(id)init
{
    self = [super init];
    if (self) {
        accuracy = [NSMutableDictionary dictionaryWithDictionary:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        detectorFeatures = [NSMutableDictionary dictionary];
//        [detectorFeatures setObject:@YES forKey:CIDetectorSmile];
//        [detectorFeatures setObject:@NO forKey:CIDetectorEyeBlink];
        
        _flags = @[@"-blink", @"-yAxis", @"-low", @"-smile"];
        _kwargs = @[@"-aspectRatio", @"-focalLength", @"-format",
                    @"-o", @"-orientation", @"-threshold"];
        
        // Allocate context for detector to operate in
        buffer = [[CIContext alloc] init];
        outputPath = @"/dev/stdout";
        outputFormatType = kJSON;
    }
    return self;
}

-(BOOL)parseArguments:(const char **)argv count:(int)argc
{
    NSString * argument, * value;
    double dNumber;
    long lNumber;
    command = [[NSString stringWithUTF8String:argv[0]] lowercaseString];
    for ( int i = 1; i < argc; i++) {
        argument = [NSString stringWithUTF8String:argv[i]];
        
        if ([_kwargs indexOfObject:argument] != NSNotFound) {
            ++i;
            // Check if we reached end
            if (i == argc) {
                [CidException throwMessage:@"%@ missing value.\n", argument];
            }
            value = [NSString stringWithUTF8String:argv[i]];
            if ([argument isEqualToString:@"-threshold"]) {
                dNumber = [value doubleValue];
                if (dNumber < 0.0 || dNumber > 1.0) {
                    [CidException throwMessage:@"-threshold must be between 0.0 & 1.0, not %f.\n", dNumber];
                }
                [accuracy setObject:[NSNumber numberWithDouble:dNumber]
                                     forKey:CIDetectorMinFeatureSize];
            } else if ([argument isEqualToString:@"-aspectRatio"]) {
                [detectorFeatures setObject:@([value floatValue])
                                     forKey:CIDetectorAspectRatio];
            } else if ([argument isEqualToString:@"-focalLength"]) {
                dNumber = [value doubleValue];
                if (dNumber < -1.0 || dNumber > 1.0) {
                    [CidException throwMessage:@"-focalLength must be between -1.0 & 1.0, not %f.\n", dNumber];
                }
                [detectorFeatures setObject:[NSNumber numberWithDouble:dNumber]
                                     forKey:CIDetectorFocalLength];
            } else if ([argument isEqualToString:@"-orientation"]) {
                lNumber = [value integerValue];
                if (lNumber < 1 || lNumber > 8 ) {
                    [CidException throwMessage:@"-orientation must be between 1 & 8, not %ld.\n", lNumber];
                }
                [detectorFeatures setObject:[NSNumber numberWithInteger:lNumber]
                                     forKey:CIDetectorImageOrientation];
            } else if ([argument isEqualToString:@"-o"]) {
                outputPath = value;
            } else if ([argument isEqualToString:@"-format"]) {
                value = [value lowercaseString];
                if ([value isEqualToString:@"json"]) {
                    outputFormatType = kJSON;
                } else if ([value isEqualToString:@"plist"]) {
                    outputFormatType = kPListXML;
                } else if ([value isEqualToString:@"plist_bin"]) {
                    outputFormatType = kPListBin;
                } else if ([value isEqualToString:@"svg"]) {
                    [detectorFeatures setObject:@YES forKey:@"yAxis"];
                    outputFormatType = kSVG;
                } else {
                    [CidException throwMessage:@"Unknown format `%@'.\n", value];
                }
            }
        } else if ([_flags indexOfObject:argument] != NSNotFound) {
            if ([argument isEqualToString:@"-low"]) {
                [accuracy setObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy];
            } else if ([argument isEqualToString:@"-blink"]) {
                [detectorFeatures setObject:@YES forKey:CIDetectorEyeBlink];
            } else if ([argument isEqualToString:@"-smile"]) {
                [detectorFeatures setObject:@YES forKey:CIDetectorSmile];
            } else if ([argument isEqualToString:@"-yAxis"]) {
                [detectorFeatures setObject:@YES forKey:@"yAxis"];
            }
        } else {
            if (inputImagePath == nil) {
                inputImagePath = argument;
            } else {
                [CidException throwMessage:@"Unknown argument `%@'.\n", argument];
            }
        }
    }
    return [self createScanner];
}
-(BOOL)createScanner
{
    if ([command isEqualToString:@"face"]) {
        scanner = [CIDetector detectorOfType:CIDetectorTypeFace context:buffer options:accuracy];
    } else if ([command isEqualToString:@"rectangle"]) {
        scanner = [CIDetector detectorOfType:CIDetectorTypeRectangle context:buffer options:accuracy];
    }  else if ([command isEqualToString:@"qr"]) {
        scanner = [CIDetector detectorOfType:CIDetectorTypeQRCode context:buffer options:accuracy];
    } else if ([command isEqualToString:@"help"] || [command isEqualToString:@"-h"]) {
        help();
        return NO;
    } else if ([command isEqualToString:@"version"] || [command isEqualToString:@"-v"]) {
        version();
        return NO;
    } else {
        [CidException throwMessage:@"Unknown command `%@'.\n", command];
    }
    return YES;
}
-(BOOL)scan
{
    CIFeature * feature;
    CIImage * source;
    NSNumber * height;
    NSArray * roi;
    
    if (inputImagePath == nil) {
        [CidException throwMessage:@"Missing input image.\n"];
    }
    if ([inputImagePath isEqualToString:@"-"]) {
        NSFileHandle * stdIn = [NSFileHandle fileHandleWithStandardInput];
        NSData * blob = [NSData dataWithData:[stdIn readDataToEndOfFile]];
        [stdIn closeFile];
        /*
         // In the rare event that we would ever want a base64 data url
        NSData * base64 = [blob base64EncodedDataWithOptions:0];
        inputImagePath = [[NSString alloc] initWithData:base64
                                               encoding:NSUTF8StringEncoding];
        */
        _inputImage = [NSURL fileURLWithPath:@"-"];
        source = [CIImage imageWithData:blob];
    } else {
        _inputImage = [NSURL fileURLWithPath:inputImagePath];
        source = [CIImage imageWithContentsOfURL:_inputImage];
    }
    if (source == nil) {
        [CidException throwMessage:@"Unable to read image @ `%@'.\n", [_inputImage absoluteString]];
    }
    extent = [source extent];
    height = [NSNumber numberWithDouble:extent.size.height];
    [detectorFeatures setObject:height forKey:@"height"];
    if ([detectorFeatures objectForKey:CIDetectorImageOrientation] == nil) {
        // Check if image has orientation influence
        id imageOrientation = [[source properties] valueForKey:@"Orientation"];
        if (imageOrientation != nil) {
            [detectorFeatures setObject:imageOrientation forKey:CIDetectorImageOrientation];
        }
    }
    roi = [scanner featuresInImage:source options:detectorFeatures];
    features = [NSMutableArray array];
    for (feature in roi) {
        [features addObject:[feature dict:detectorFeatures]];
    }
    return YES;
}
-(BOOL)print
{
    CidSerializer * serializer = [CidSerializer serializerWithList:features
                                                      outputFormat:outputFormatType];
    [[serializer data:self] writeToFile:outputPath atomically:NO];
    return YES;
}
-(CGRect)extent
{
    return extent;
}
@end
