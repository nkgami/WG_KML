//
//  ColorConverter.m
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/20.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import "ColorConverter.h"

@implementation ColorConverter

NSString *_str_color;

- (void)set_str:(NSString *)str
{
    _str_color = str;
}

- (float)get_red
{
    NSString *sc = [_str_color substringWithRange:NSMakeRange(0, 2)];
    unsigned int colorf = 0;
    NSScanner *scanner = [NSScanner scannerWithString:sc];
    [scanner scanHexInt:&colorf];
    return (float)colorf / (float)255;
}
- (float)get_green
{
    NSString *sc = [_str_color substringWithRange:NSMakeRange(2, 2)];
    unsigned int colorf = 0;
    NSScanner *scanner = [NSScanner scannerWithString:sc];
    [scanner scanHexInt:&colorf];
    return (float)colorf / (float)255;
}

- (float)get_blue
{
    NSString *sc = [_str_color substringWithRange:NSMakeRange(4, 2)];
    unsigned int colorf = 0;
    NSScanner *scanner = [NSScanner scannerWithString:sc];
    [scanner scanHexInt:&colorf];
    return (float)colorf / (float)255;
}

- (float)get_alpha
{
    NSString *sc = [_str_color substringWithRange:NSMakeRange(6, 2)];
    unsigned int colorf = 0;
    NSScanner *scanner = [NSScanner scannerWithString:sc];
    [scanner scanHexInt:&colorf];
    return (float)1 - (float)colorf / (float)255;
}


@end
