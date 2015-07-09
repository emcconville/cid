//
//  CidTypes.h
//  cid
//
//  Created by Eric McConville on 7/8/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#ifndef cid_CidTypes_h
#define cid_CidTypes_h

// Common Dict Keys
extern NSString * const kX;
extern NSString * const kY;
extern NSString * const kWidth;
extern NSString * const kHeight;
extern NSString * const kYAxis;
extern NSString * const kMessage;
extern NSString * const kLeftEye;
extern NSString * const kRightEye;
extern NSString * const kMouth;
extern NSString * const kTopLeft;
extern NSString * const kTopRight;
extern NSString * const kBottomLeft;
extern NSString * const kBottomRight;
extern NSString * const kClosed;
extern NSString * const kSmile;

// Commands
extern NSString * const kFace;
extern NSString * const kRectangle;
extern NSString * const kQR;
extern NSString * const kHelp;
extern NSString * const kVersion;

// Argument Flags
extern NSString * const fLow;
extern NSString * const fBlink;
extern NSString * const fSmile;
extern NSString * const fYAxis;

// Argument Kwargs
extern NSString * const wAspectRatio;
extern NSString * const wFocalLength;
extern NSString * const wFormat;
extern NSString * const wOut;
extern NSString * const wOrientation;
extern NSString * const wThreshold;

#endif
