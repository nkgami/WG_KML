//
//  WG_KMLStyleContainer.h
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/22.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KML.h"

@interface WG_KMLStyleContainer : NSObject
@property KMLIconStyle *icon;
@property KMLLineStyle *line;
@property KMLPolyStyle *poly;
-(void)setStyles:(KMLStyle *)kmlStyle;
@end
