//
//  WG_KMLStyleContainer.m
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/22.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import "WG_KMLStyleContainer.h"

@implementation WG_KMLStyleContainer
-(void)setStyles:(KMLStyle *)kmlStyle{
    if(kmlStyle.iconStyle != nil){
        _icon = kmlStyle.iconStyle;
    }
    if(kmlStyle.lineStyle != nil){
        _line = kmlStyle.lineStyle;
    }
    if(kmlStyle.polyStyle != nil){
        _poly = kmlStyle.polyStyle;
    }
}
@end
