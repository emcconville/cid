//
//  CIFeature+Dict.m
//  cid
//
//  Created by Eric McConville on 7/6/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import "CIFeature+Dict.h"

static double __image_height__ = 0;
static int __invert_y_axis__ = 0;

NSDictionary * (^rectToObject)(CGRect) = ^(CGRect rect)
{
    return @{@"x" : @(rect.origin.x),
             @"y" : @(__invert_y_axis__ ? __image_height__ - rect.origin.y - rect.size.height : rect.origin.y),
             @"width" : @(rect.size.width),
             @"height" : @(rect.size.height)};
};

NSDictionary * (^pointToObject)(CGPoint) = ^(CGPoint point)
{
    return @{@"x" : @(point.x),
             @"y" : @(__invert_y_axis__ ? __image_height__ - point.y : point.y)};
};


@implementation CIFeature (Dict)
-(NSMutableDictionary  * )_processFaceAttributes:(NSMutableDictionary *)outDict withBlink:(BOOL)closed withSmile:(BOOL)smile
{
    
    CIFaceFeature * this = (CIFaceFeature *)self;
    NSMutableDictionary * subFeature;
    if ([this hasLeftEyePosition]) {
        subFeature = [NSMutableDictionary dictionaryWithDictionary:pointToObject([this leftEyePosition])];
        if (closed) {
            [subFeature setObject:@([this leftEyeClosed]) forKey:@"closed"];
        }
        [outDict setObject:[subFeature copy] forKey:@"leftEye"];
    }
    if ([this hasRightEyePosition]) {
        subFeature = [NSMutableDictionary dictionaryWithDictionary:pointToObject([this rightEyePosition])];
        if (closed) {
            [subFeature setObject:@([this rightEyeClosed]) forKey:@"closed"];
        }
        [outDict setObject:[subFeature copy] forKey:@"rightEye"];
    }
    if ([this hasMouthPosition]) {
        subFeature = [NSMutableDictionary dictionaryWithDictionary:pointToObject([this mouthPosition])];
        if (smile) {
            [subFeature setObject:@([this hasSmile]) forKey:@"smile"];
        }
        [outDict setObject:[subFeature copy] forKey:@"mouth"];
    }
    return outDict;
}
-(NSMutableDictionary *)_processRetangleAttribute:(NSMutableDictionary *)outDict
{
    CIRectangleFeature * this = (CIRectangleFeature *)self;
    [outDict setObject:pointToObject([this topLeft    ]) forKey:@"topLeft"    ];
    [outDict setObject:pointToObject([this topRight   ]) forKey:@"topRight"   ];
    [outDict setObject:pointToObject([this bottomLeft ]) forKey:@"bottomLeft" ];
    [outDict setObject:pointToObject([this bottomRight]) forKey:@"bottomRight"];
    return outDict;
}
-(NSDictionary *)dict:(NSDictionary *)options
{
    BOOL invertY = [[options objectForKey:@"yAxis"] boolValue];
    if (invertY) {
        __invert_y_axis__ = 1;
        __image_height__ = [[options objectForKey:@"height"] doubleValue];
    }
    CGRect mbr = [self bounds];
    NSMutableDictionary * outDict = [NSMutableDictionary dictionaryWithDictionary:rectToObject(mbr)];
    if ([self isKindOfClass:[CIFaceFeature class]]) {
        BOOL blink = [[options objectForKey:CIDetectorEyeBlink] boolValue];
        BOOL smile = [[options objectForKey:CIDetectorSmile] boolValue];
        outDict = [self _processFaceAttributes:outDict
                                     withBlink:blink
                                     withSmile:smile];
    } else {
        outDict = [self _processRetangleAttribute:outDict];
        if ([self isKindOfClass:[CIQRCodeFeature class]]) {
            NSString * message = [(CIQRCodeFeature *)self messageString];
            [outDict setObject:message forKey:@"message"];
        }
    }
    return [outDict copy];
}

@end
