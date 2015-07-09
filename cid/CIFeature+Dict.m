//
//  CIFeature+Dict.m
//  cid
//
//  Created by Eric McConville on 7/6/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import "CIFeature+Dict.h"
#import "CidTypes.h"

static double __image_height__ = 0;
static int __invert_y_axis__ = 0;

NSDictionary * (^rectToObject)(CGRect) = ^(CGRect rect)
{
    // lrint = double to
    return @{kX : @(lrint(rect.origin.x)),
             kY : @(__invert_y_axis__ ? lrint(__image_height__ - rect.origin.y - rect.size.height) : lrint(rect.origin.y)),
             kWidth : @(lrint(rect.size.width)),
             kHeight : @(lrint(rect.size.height))};
};

NSDictionary * (^pointToObject)(CGPoint) = ^(CGPoint point)
{
    return @{kX : @(lrint(point.x)),
             kY : @(__invert_y_axis__ ? lrint(__image_height__ - point.y) : lrint(point.y))};
};


@implementation CIFeature (Dict)
-(NSMutableDictionary  * )_processFaceAttributes:(NSMutableDictionary *)outDict withBlink:(BOOL)closed withSmile:(BOOL)smile
{
    
    CIFaceFeature * this = (CIFaceFeature *)self;
    NSMutableDictionary * subFeature;
    if ([this hasLeftEyePosition]) {
        subFeature = [NSMutableDictionary dictionaryWithDictionary:pointToObject([this leftEyePosition])];
        if (closed) {
            [subFeature setObject:@([this leftEyeClosed]) forKey:kClosed];
        }
        [outDict setObject:[subFeature copy] forKey:kLeftEye];
    }
    if ([this hasRightEyePosition]) {
        subFeature = [NSMutableDictionary dictionaryWithDictionary:pointToObject([this rightEyePosition])];
        if (closed) {
            [subFeature setObject:@([this rightEyeClosed]) forKey:kClosed];
        }
        [outDict setObject:[subFeature copy] forKey:kRightEye];
    }
    if ([this hasMouthPosition]) {
        subFeature = [NSMutableDictionary dictionaryWithDictionary:pointToObject([this mouthPosition])];
        if (smile) {
            [subFeature setObject:@([this hasSmile]) forKey:kSmile];
        }
        [outDict setObject:[subFeature copy] forKey:kMouth];
    }
    return outDict;
}
-(NSMutableDictionary *)_processRetangleAttribute:(NSMutableDictionary *)outDict
{
    CIRectangleFeature * this = (CIRectangleFeature *)self;
    [outDict setObject:pointToObject([this topLeft    ]) forKey:kTopLeft    ];
    [outDict setObject:pointToObject([this topRight   ]) forKey:kTopRight   ];
    [outDict setObject:pointToObject([this bottomLeft ]) forKey:kBottomLeft ];
    [outDict setObject:pointToObject([this bottomRight]) forKey:kBottomRight];
    return outDict;
}
-(NSDictionary *)dict:(NSDictionary *)options
{
    BOOL blink, smile;
    NSMutableDictionary * outDict;
    NSString * message;
    
    if ([[options objectForKey:kYAxis] boolValue]) {
        __invert_y_axis__ = 1;
        __image_height__ = [[options objectForKey:kHeight] doubleValue];
    }
    CGRect mbr = [self bounds];
    outDict = [NSMutableDictionary dictionaryWithDictionary:rectToObject(mbr)];
    if ([self isKindOfClass:[CIFaceFeature class]]) {
        blink = [[options objectForKey:CIDetectorEyeBlink] boolValue];
        smile = [[options objectForKey:CIDetectorSmile] boolValue];
        outDict = [self _processFaceAttributes:outDict
                                     withBlink:blink
                                     withSmile:smile];
    } else {
        outDict = [self _processRetangleAttribute:outDict];
        if ([self isKindOfClass:[CIQRCodeFeature class]]) {
            message = [(CIQRCodeFeature *)self messageString];
            [outDict setObject:message forKey:kMessage];
        }
    }
    return [outDict copy];
}

@end
