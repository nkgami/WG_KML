//
//  NSStringHash.m
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/11/08.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import "NSStringHash.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Hash)

- (NSString *)MD5Hash
{
    const char *data = [self UTF8String];
    if (self.length == 0) {
        return nil;
    }
    CC_LONG len = (CC_LONG)self.length;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data, len, result);
    NSMutableString *ms = @"".mutableCopy;
    for (int i = 0; i < 16; i++) {
        [ms appendFormat:@"%02X",result[i]];
    }
    return ms;
}

@end