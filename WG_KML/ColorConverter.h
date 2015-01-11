//
//  ColorConverter.h
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/20.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

//Convert color style from #ffffffff to 1.0 1.0 1.0 1.0

#import <Foundation/Foundation.h>

@interface ColorConverter : NSObject
- (void)set_str:(NSString *)str;//set str_color
- (float)get_red;
- (float)get_green;
- (float)get_blue;
- (float)get_alpha;
@property NSString *str_color;//color string like ff0022ff

@end
