//
//  CidSerializor.m
//  cid
//
//  Created by Eric McConville on 7/5/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import "CidSerializer.h"
#import "CidApp.h"

@implementation CidSerializer
@synthesize type;
-(id)initWithList:(NSArray *)list_
{
    self = [super init];
    if (self) {
        list = list_;
        [self setType:kJSON];
    }
    return self;
}
+(CidSerializer *)serializerWithList:(NSArray *)list_ outputFormat:(OutputFormatType)type_
{
    CidSerializer * this = [[CidSerializer alloc] initWithList:list_];
    [this setType:type_];
    return this;
}
-(NSData *)data:(CidApp *)app {
    NSError * error;
    NSData * outBlob;
    switch ([self type]) {
        case kPListBin : {
            outBlob = [NSPropertyListSerialization dataWithPropertyList:list
                                                                 format:NSPropertyListBinaryFormat_v1_0
                                                                options:0
                                                                  error:&error];
            break;
        }
        case kPListXML : {
            outBlob = [NSPropertyListSerialization dataWithPropertyList:list
                                                                 format:NSPropertyListXMLFormat_v1_0
                                                                options:0
                                                                  error:&error];
            break;
        }
        case kSVG : {
            NSDictionary * feat, * subFeat;
            NSString * header = @"<?xml version=\"1.0\"?>\n"
            @"<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"%0.0f\" height=\"%0.0f\" viewbox=\"%0.0f %0.0f %0.0f %0.0f\">\n"
            @"<style>rect, circle {stroke-width: 2px; fill: transparent; }"
            @"circle { stroke: blue; } rect { stroke: red; } svg { background: transparent url('%@') no-repeat; }</style>\n";
            NSString * retangle = @"\t<rect x=\"%ld\" y=\"%ld\" width=\"%ld\" height=\"%ld\" />\n";
            NSString * point = @"\t<circle cx=\"%ld\" cy=\"%ld\" r=\"2\" />\n";
            NSString * group = @"<g>\n%@</g>\n";
            CGRect E = [app extent];
            NSString * dom = [NSString stringWithFormat:header,
                              E.size.width,
                              E.size.height,
                              E.origin.x,
                              E.origin.y,
                              E.size.width,
                              E.size.height,
                              [[app inputImage] absoluteString]];
            NSString * tmp;
            for (feat in list) {
                tmp = [NSString stringWithFormat:retangle,
                       [[feat objectForKey:@"x"] longValue],
                       [[feat objectForKey:@"y"] longValue],
                       [[feat objectForKey:@"width"] longValue],
                       [[feat objectForKey:@"height"] longValue]
                       ];
                for (NSString * key in @[@"leftEye", @"rightEye", @"mouth",
                                         @"topLeft", @"topRight", @"bottomLeft",
                                         @"bottomRight",]) {
                    if ((subFeat = [feat objectForKey:key]) != nil) {
                        tmp = [tmp stringByAppendingString:[NSString stringWithFormat:point,
                                                            [[subFeat objectForKey:@"x"] longValue],
                                                            [[subFeat objectForKey:@"y"] longValue]]];
                    }
                }
                dom = [dom stringByAppendingString:[NSString stringWithFormat:group, tmp]];
            }
            outBlob = [[dom stringByAppendingString:@"</svg>"] dataUsingEncoding:NSUTF8StringEncoding];
            break;
        }
        case kJSON :
        {
            outBlob = [NSJSONSerialization dataWithJSONObject:list
                                                      options:NSJSONWritingPrettyPrinted
                                                        error:&error];
            break;
        }
    }
    return outBlob;
}
@end
