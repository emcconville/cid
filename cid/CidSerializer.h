//
//  CidSerializor.h
//  cid
//
//  Created by Eric McConville on 7/5/15.
//  Copyright (c) 2015 emcconville. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CidApp;

typedef enum OutputFormatType {
    kJSON,
    kPListBin,
    kPListXML,
    kSVG,
} OutputFormatType;

@interface CidSerializer : NSObject {
    NSArray * list;
}
@property (nonatomic) OutputFormatType type;
-(id)initWithList:(NSArray *)list_;
+(CidSerializer *)serializerWithList:(NSArray *)list_ outputFormat:(OutputFormatType)type_;
/**
 * @brief Serialize list of features into a common transport format.
 * @param app In the event that meta-data/user-info is needed by serializers.
 * @return UTF-8 encoded string data.
 */
-(NSData *)data:(CidApp *)app;
@end
