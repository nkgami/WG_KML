//
//  WG_KML.h
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/20.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhirlyGlobeComponent.h"

@interface WG_KML : NSObject
{
    bool kmzflag;
    NSString *kmzDir;
    NSString *kmzmainkml;
    NSMutableArray *overlays;
    NSMutableArray *networklinks;
    NSMutableArray *mOjects;
    bool root_flag;
    NSMutableArray *childKml;
    NSMutableDictionary *styles;
}
@property NSString *filePath;
@property WhirlyGlobeViewController *theViewC;
-(void)loadicons;
-(void)loadpolys;
-(void)loadlines;
-(void)loadgroundoverlay;
-(int)loadkmz;
-(int)download:(NSString *)surl;
-(void)removeall;
-(void)loadnetworklinks;
-(id)init;
@end
