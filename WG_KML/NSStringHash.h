//
//  NSStringHash.h
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/11/08.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

//Get MD5 Hash from String

#import <Foundation/Foundation.h>

@interface NSString (Hash)

- (NSString*)MD5Hash;

@end
