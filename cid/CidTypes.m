//
//  CidTypes.m
//  cid
//
//  Created by Eric McConville on 7/8/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CidTypes.h"

NSString * const kX = @"x";
NSString * const kY = @"y";
NSString * const kWidth = @"width";
NSString * const kHeight = @"height";
NSString * const kYAxis = @"yAxis";
NSString * const kMessage = @"message";
NSString * const kLeftEye = @"leftEye";
NSString * const kRightEye = @"rightEye";
NSString * const kMouth = @"mouth";
NSString * const kTopLeft = @"topLeft";
NSString * const kTopRight = @"topRight";
NSString * const kBottomLeft = @"bottomLeft";
NSString * const kBottomRight = @"bottomRight";
NSString * const kClosed = @"closed";
NSString * const kSmile = @"smile";



// Commands
NSString * const kFace = @"face";
NSString * const kRectangle = @"rectangle";
NSString * const kQR = @"qr";
NSString * const kHelp = @"help";
NSString * const kVersion = @"version";

// Flags
NSString * const fLow = @"-low";
NSString * const fBlink = @"-blink";
NSString * const fSmile = @"-smile";
NSString * const fYAxis = @"-yAxis";

// Kwargs
NSString * const wAspectRatio = @"-aspectRatio";
NSString * const wFocalLength = @"-focalLength";
NSString * const wFormat = @"-format";
NSString * const wOut = @"-o";
NSString * const wOrientation = @"-orientation";
NSString * const wThreshold= @"-threshold";
