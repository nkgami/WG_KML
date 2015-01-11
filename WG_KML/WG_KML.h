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
    bool kmzflag;//if the file is kmz, true
    NSString *kmzDir;//directory path of the unzipped kmz
    NSString *kmzmainkml;//file path of the main kml file in kmz
    NSMutableArray *overlays;//contain overlay elements
    NSMutableArray *networklinks;//contain networklink elements
    NSMutableArray *mOjects;//push already showed ojects
    bool root_flag;//if instance is the root of the kml tree, true
    NSMutableArray *childKml;//contain all child kml files
    NSMutableDictionary *styles;//contain style data
    UIProgressView *pv;//view to show progress
    UILabel *texlab;//text label to show progress
    
    //for debug
    int element_count;
    int num_of_pixel;
}
@property NSString *filePath;//local path of kml or kmz file
@property WhirlyGlobeViewController *theViewC;//need to set
-(void)setProgressView:(UIProgressView *)pv_in;
-(void)setProgressLabel:(UILabel *)lab_in;
-(void)loadicons;
-(void)loadpolys;
-(void)loadlines;
-(void)loadgroundoverlay;
-(int)loadkmz;
-(int)download:(NSString *)surl;
-(void)removeall;
-(void)loadnetworklinks;
-(void)clearChildren;
-(id)init;
@end
