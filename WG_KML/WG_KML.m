//
//  WG_KML.m
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/20.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import "WG_KML.h"
#import "WhirlyGlobeComponent.h"
#import "KML.h"
#import "ColorConverter.h"
#import <UIKit/UIKit.h>
#import "WG_KMLStyleContainer.h"
#import "ZipArchive.h"
#import "NSStringHash.h"

@implementation WG_KML
- (id)init
{
    childKml = [NSMutableArray array];
    styles = [NSMutableDictionary dictionary];
    return [self initChild:true child:childKml styled:styles];
    pv = nil;
    texlab = nil;
    element_count = 0;
    num_of_pixel = 0;
}

//init method to create child kml of networklink
- (id)initChild:(bool)flag child:(NSMutableArray *)cary styled:(NSMutableDictionary *) style
{
    mOjects = [NSMutableArray array];
    kmzflag = false;
    childKml = cary;
    root_flag = flag;
    styles = style;
    element_count = 0;
    num_of_pixel = 0;
    return self;
    
}

//need to set progress view to show progress alart view
-(void)setProgressView:(UIProgressView *)pv_in{
    pv = pv_in;
}
-(void)setProgressLabel:(UILabel *)lab_in{
    texlab = lab_in;
}
-(unsigned long)numofkml{
    return ([childKml count] + 1);
}

//loading method for Icon
-(void)loadicons
{
    WG_KMLStyleContainer *defaultstyle;
    NSMutableDictionary *iconcache = [NSMutableDictionary dictionary];
    NSError *error;
    NSString *text;
    text = [self getText:error];
    if(text == nil){
        return;
    }
    //parsing kml
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    //get stles from styleSelectors
    defaultstyle = [self getStyles:styles styleselector:root.feature.styleSelectors];
    
    //load each placemark
    NSArray *placemarks = [root placemarks];
    for (id object in placemarks) {
        KMLPlacemark *place = object;
        float latitude = 0,longitude = 0, altitude = 0;

        //set styles
        WG_KMLStyleContainer *pstyle = nil;
        pstyle = [self setStyle:place];
        if(pstyle == nil){
            pstyle = defaultstyle;
        }
        float iconscale;
        NSString *pngpath;
        NSString *color;
        
        //set scale
        if(pstyle != nil && pstyle.icon.scale != 0){
            iconscale = pstyle.icon.scale;
        }
        else{
            iconscale = 1;
        }
        //set icon image
        if(pstyle != nil && pstyle.icon.icon.href != nil){
            pngpath = pstyle.icon.icon.href;
        }
        else{//default icon
            pngpath = @"http://maps.google.com/mapfiles/kml/paddle/red-circle.png";
        }
        //set icon color
        if(pstyle != nil && pstyle.icon.color != nil){
            color = pstyle.icon.color;
        }
        else{
            color = nil;
        }
        if(place.style.iconStyle.color != nil){
            color = place.style.iconStyle.color;
        }
        else{
            color = nil;
        }
        //set png image
        UIImage *pngImage;
        if([iconcache objectForKey:pngpath] == nil){
            pngImage = [self load_img:pngpath];
            if(pngImage != nil){
                [iconcache setObject:pngImage forKey:pngpath];
            }
        }
        else{
            pngImage = (UIImage *)[iconcache objectForKey:pngpath];
        }
        //Sometimes geometry for placemark is MultiGeometry.
        //need to find the latitude and longitude
        bool multi_flag = false;
        if([place.geometry isKindOfClass:[KMLMultiGeometry class]]){
            for ( KMLAbstractGeometry *x in ((KMLMultiGeometry *)place.geometry).geometries ) {
                if([x isKindOfClass:[KMLPoint class]]){
                    latitude = ((KMLPoint *)x).coordinate.latitude;
                    longitude = ((KMLPoint *)x).coordinate.longitude;
                    altitude = ((KMLPoint *)x).coordinate.altitude;
                    multi_flag = true;
                    break;
                }
                else{
                    continue;
                }
            }
            if(!multi_flag){
                continue;
            }
        }
        else if([place.geometry isKindOfClass:[KMLPoint class]]){
            latitude = ((KMLPoint *)place.geometry).coordinate.latitude;
            longitude = ((KMLPoint *)place.geometry).coordinate.longitude;
            altitude = ((KMLPoint *)place.geometry).coordinate.altitude;
        }
        else{
            continue;
        }
        // Create a Screen Marker
        MaplyScreenMarker *marker_p = [[MaplyScreenMarker alloc] init];
        marker_p.loc = MaplyCoordinateMakeWithDegrees(longitude, latitude);
        marker_p.image = pngImage;
        marker_p.size = CGSizeMake(20 * iconscale,20 * iconscale);//magic number:20
        marker_p.layoutImportance = MAXFLOAT;
        marker_p.userObject = place.name;
        if(color != nil){
            ColorConverter *cv = [[ColorConverter alloc] init];
            [cv set_str:color];
            marker_p.color = [UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]];
        }
        marker_p.selectable = YES;
        MaplyComponentObject *addobj
        = [_theViewC addScreenMarkers:@[marker_p] desc:nil mode:MaplyThreadAny];
        if(addobj != nil){
            [mOjects addObject:addobj];
        }
    }
    //show progress and load from child kml
    int count = 1;
    if(pv != nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            pv.progress = (float)count/(float)[self numofkml];
        });
    }
    if(texlab != nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            texlab.text = [NSString stringWithFormat:@"loading icons %d / %d",
                           count,(int)[self numofkml]];
        });
    }
    if(root_flag){
        for(WG_KML *wg_kml_child in childKml){
            [wg_kml_child loadicons];
            count += 1;
            if(pv != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    pv.progress = (float)count/(float)[self numofkml];
                });
            }
            if(texlab != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    texlab.text = [NSString stringWithFormat:@"loading icons %d / %d",
                                   count,(int)[self numofkml]];
                });
            }
        }
    }
}

//loading method for Polygon
-(void)loadpolys
{
    WG_KMLStyleContainer *defaultstyle;
    NSError *error;
    NSString *text;
    text = [self getText:error];
    if(text == nil){
        return;
    }
    //parsing kml
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    //load styles
    defaultstyle = [self getStyles:styles styleselector:root.feature.styleSelectors];
    
    //load each placemark
    NSArray *placemarks = [root placemarks];
    for (id object in placemarks) {
        KMLPlacemark *place = object;
        //set styles
        WG_KMLStyleContainer *pstyle = nil;
        pstyle = [self setStyle:place];
        if(pstyle == nil){
            pstyle = defaultstyle;
        }
        //set color of polygon
        NSString *color;
        if(pstyle != nil && pstyle.poly.color != nil){
            color = pstyle.poly.color;
        }
        else{
            color = nil;
        }
        if(place.style.polyStyle.color != nil){
            color = place.style.polyStyle.color;
        }
        else{
            color = nil;
        }
        MaplyComponentObject *addobj;
        //load geometry of polygon
        if([place.geometry isKindOfClass:[KMLMultiGeometry class]]){
        float latitude = 0,longitude = 0;
            for ( KMLAbstractGeometry *x in ((KMLMultiGeometry *)place.geometry).geometries ) {
                if([x isKindOfClass:[KMLPoint class]]){
                    latitude = ((KMLPoint *)x).coordinate.latitude;
                    longitude = ((KMLPoint *)x).coordinate.longitude;
                }
                else if([x isKindOfClass:[KMLPolygon class]]){
                    NSArray *line_points = ((KMLPolygon *)x).outerBoundaryIs.coordinates;
                    MaplyCoordinate coords[[line_points count]];
                    int i = 0;
                    for(KMLCoordinate *y in line_points){
                        coords[i] = MaplyCoordinateMakeWithDegrees(y.longitude, y.latitude);
                        i += 1;
                    }
                    MaplyVectorObject *sfOutline = [[MaplyVectorObject alloc] initWithAreal:coords numCoords:i attributes:nil];
                        
                    ColorConverter *cv = [[ColorConverter alloc] init];
                    [cv set_str:color];
                    UIColor *cl = [UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]];
                    addobj = [_theViewC addVectors:@[sfOutline] desc:@{kMaplyColor: cl,
                                                                       kMaplyFilled:@YES}];
                    //[_theViewC addLoftedPolys:@[sfOutline] key:nil cache:nil desc:@{kMaplyColor: cl,kMaplyLoftedPolyHeight:@0.002}];
                    if(addobj != nil){
                        [mOjects addObject:addobj];
                    }
                    
                }
                else{
                    continue;
                }
            }
        }
        else if([place.geometry isKindOfClass:[KMLPolygon class]]){
            KMLPolygon *x = (KMLPolygon *)place.geometry;
            NSArray *line_points = ((KMLPolygon *)x).outerBoundaryIs.coordinates;
            MaplyCoordinate coords[[line_points count]];
            int i = 0;
            for(KMLCoordinate *y in line_points){
                coords[i] = MaplyCoordinateMakeWithDegrees(y.longitude, y.latitude);
                i += 1;
            }
            MaplyVectorObject *sfOutline = [[MaplyVectorObject alloc] initWithAreal:coords numCoords:i attributes:nil];
                
            ColorConverter *cv = [[ColorConverter alloc] init];
            [cv set_str:color];
            UIColor *cl = [UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]];
            addobj = [_theViewC addVectors:@[sfOutline] desc:@{kMaplyColor: cl,
                                                          kMaplyFilled:@YES}];
            //[_theViewC addLoftedPolys:@[sfOutline] key:nil cache:nil desc:@{kMaplyColor: cl,kMaplyLoftedPolyHeight:@0.002}];
            if(addobj != nil){
                [mOjects addObject:addobj];
            }
        }
    }
    //renew progress and load from child kml
    int count = 1;
    if(pv != nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            pv.progress = (float)count/(float)[self numofkml];
        });
    }
    if(texlab != nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            texlab.text = [NSString stringWithFormat:@"loading polys %d / %d",
                           count,(int)[self numofkml]];
        });
    }
    if(root_flag){
        for(WG_KML *wg_kml_child in childKml){
            [wg_kml_child loadpolys];
            count += 1;
            if(pv != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    pv.progress = (float)count/(float)[self numofkml];
                });
            }
            if(texlab != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    texlab.text = [NSString stringWithFormat:@"loading polys %d / %d",
                                   count,(int)[self numofkml]];
                });
            }
        }
    }
}

//loading method for LineString
-(void)loadlines
{
    WG_KMLStyleContainer *defaultstyle;
    NSError *error;
    NSString *text;
    text = [self getText:error];
    if(text == nil){
        return;
    }
    //parsing kml
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    //load styles
    defaultstyle = [self getStyles:styles styleselector:root.feature.styleSelectors];
    
    //load each placemark
    NSArray *placemarks = [root placemarks];
    for (id object in placemarks) {
        KMLPlacemark *place = object;
        //set styles
        WG_KMLStyleContainer *pstyle = nil;
        pstyle = [self setStyle:place];
        if(pstyle == nil){
            pstyle = defaultstyle;
        }
        //set color
        NSString *color;
        if(pstyle != nil && pstyle.line.color != nil){
            color = pstyle.line.color;
        }
        else{
            color = nil;
        }
        if(place.style.lineStyle.color != nil){
            color = place.style.lineStyle.color;
        }
        else{
            color = nil;
        }
        MaplyComponentObject *addobj;
        //loading geometry of linestring
        if([place.geometry isKindOfClass:[KMLMultiGeometry class]]){
            float latitude = 0,longitude = 0;
            for ( KMLAbstractGeometry *x in ((KMLMultiGeometry *)place.geometry).geometries ) {
                if([x isKindOfClass:[KMLPoint class]]){
                    latitude = ((KMLPoint *)x).coordinate.latitude;
                    longitude = ((KMLPoint *)x).coordinate.longitude;
                }
                else if([x isKindOfClass:[KMLLineString class]]){
                    NSArray *line_points = ((KMLLineString *)x).coordinates;
                    MaplyCoordinate coords[[line_points count]];
                    int i = 0;
                    for(KMLCoordinate *y in line_points){
                        coords[i] = MaplyCoordinateMakeWithDegrees(y.longitude, y.latitude);
                        i += 1;
                    }
                    MaplyVectorObject *sfOutline = [[MaplyVectorObject alloc] initWithAreal:coords numCoords:i attributes:nil];
                    if(color != nil){
                        
                        ColorConverter *cv = [[ColorConverter alloc] init];
                        [cv set_str:color];
                        UIColor *cl = [UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]];
                        addobj = [_theViewC addVectors:@[sfOutline] desc:@{kMaplyColor: cl,
                                                                  kMaplyFilled:@NO}];
                        [mOjects addObject:addobj];
                        element_count += 1;
                    }
                    else{
                        addobj = [_theViewC addVectors:@[sfOutline] desc:@{kMaplyFilled:@NO}];
                        [mOjects addObject:addobj];
                        element_count += 1;
                    }
                }
            }
        }
        else if([place.geometry isKindOfClass:[KMLLineString class]]){
            KMLLineString *x = (KMLLineString *)place.geometry;
            NSArray *line_points = ((KMLLineString *)x).coordinates;
            MaplyCoordinate coords[[line_points count]];
            int i = 0;
            for(KMLCoordinate *y in line_points){
                coords[i] = MaplyCoordinateMakeWithDegrees(y.longitude, y.latitude);
                i += 1;
            }
            MaplyVectorObject *sfOutline = [[MaplyVectorObject alloc] initWithAreal:coords numCoords:i attributes:nil];
                
            ColorConverter *cv = [[ColorConverter alloc] init];
            [cv set_str:color];
            UIColor *cl = [UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]];
            addobj = [_theViewC addVectors:@[sfOutline] desc:@{kMaplyColor: cl,
                                                          kMaplyFilled:@NO}];
            if(addobj != nil){
                [mOjects addObject:addobj];
                element_count += 1;
            }
        }
    }
    //for debug
    NSLog(@"%d",element_count);
    //renew progress and loading from child kml
    int count = 1;
    if(pv != nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            pv.progress = (float)count/(float)[self numofkml];
        });
    }
    if(texlab != nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            texlab.text = [NSString stringWithFormat:@"loading lines %d / %d",
                           count,(int)[self numofkml]];
        });
    }
    if(root_flag){
        for(WG_KML *wg_kml_child in childKml){
            [wg_kml_child loadlines];
            count += 1;
            if(pv != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    pv.progress = (float)count/(float)[self numofkml];
                });
            }
            if(texlab != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    texlab.text = [NSString stringWithFormat:@"loading lines %d / %d",
                                   count,(int)[self numofkml]];
                });
            }
        }
    }
}

//loading method for kmz file
-(int)loadkmz
{
    NSString *zipPath = _filePath;//path of kmz file
    NSString *outfile = [_filePath MD5Hash];//output file name
    NSString *zipFolder = [@"tmp/" stringByAppendingString:outfile];//output under tmp
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *outDir = [NSHomeDirectory() stringByAppendingPathComponent:zipFolder];//output directory
    int p = 0;
    //to avoid hash collision
    while([fileManager fileExistsAtPath:outDir]){
        zipFolder = [[_filePath stringByAppendingString:
                      [NSString stringWithFormat:@"%d", p]] MD5Hash];
        outDir = [NSHomeDirectory() stringByAppendingPathComponent:zipFolder];
        p += 1;
    }
    ZipArchive *zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:zipPath];
    BOOL result = [zip UnzipFileTo:outDir overWrite:true];
    if(result == YES )
    {
        //find main kml file in kmz
        NSArray *list = [fileManager contentsOfDirectoryAtPath:outDir error:&error];
        for (NSString *path in list) {
            if([[path substringFromIndex:([path length] - 4)] isEqualToString:@".kml"]){
                kmzDir = [NSString stringWithFormat:@"%@/",outDir];
                kmzflag = true;
                kmzmainkml = [kmzDir stringByAppendingString:path];
            }
        }
    }
    if(kmzflag == false){
        return -1;
    }
    else{
        return 0;
    }
}

//loading method for GroundOverlay
-(void)loadgroundoverlay
{
    NSError *error;
    NSString *text;
    overlays = [NSMutableArray array];
    text = [self getText:error];
    if(text == nil){
        return;
    }
    //parsing kml
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    //get GroundOverlay element
    KMLAbstractContainer *container = (KMLAbstractContainer *)(root.feature);
    [self getOverlay:container type:@"Ground"];
    //load each overlay element
    for(NSObject *aobj in overlays){
        KMLGroundOverlay *goverlay = (KMLGroundOverlay *)aobj;
        CGFloat north, south, east, west;
        north = goverlay.latLonBox.north;
        south = goverlay.latLonBox.south;
        east = goverlay.latLonBox.east;
        west = goverlay.latLonBox.west;
        NSString *imagepath = goverlay.icon.href;
        UIImage *imgImage = [self load_img:imagepath];
        num_of_pixel += imgImage.size.height * imgImage.size.width;
        MaplySticker *mstick = [[MaplySticker alloc] init];
        mstick.image = imgImage;
        mstick.ll = MaplyCoordinateMakeWithDegrees(west, south);
        mstick.ur = MaplyCoordinateMakeWithDegrees(east, north);
        MaplyComponentObject *addobj;
        addobj = [_theViewC addStickers:@[mstick] desc:nil];
        if(addobj != nil){
            [mOjects addObject:addobj];
        }
    }
    //for debug
    NSLog(@"%d",num_of_pixel);
    //renew progress and load from child kml
    int count = 1;
    if(pv != nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            pv.progress = (float)count/(float)[self numofkml];
        });
    }
    if(texlab != nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            texlab.text = [NSString stringWithFormat:@"loading overlays %d / %d",
                           count,(int)[self numofkml]];
        });
    }
    if(root_flag){
        for(WG_KML *wg_kml_child in childKml){
            [wg_kml_child loadgroundoverlay];
            count += 1;
            if(pv != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    pv.progress = (float)count/(float)[self numofkml];
                });
            }
            if(texlab != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    texlab.text = [NSString stringWithFormat:@"loading overlays %d / %d",
                                   count,(int)[self numofkml]];
                });
            }
        }
    }
}
//find overlay elements in kml under AbstractContainer
- (void)getOverlay:(KMLAbstractContainer *)container type:(NSString *)deftype
{
    if([deftype isEqualToString:@"Ground"] &&
       [container isKindOfClass:[KMLGroundOverlay class]]){
        [overlays addObject:container];
        return;
    }
    if([deftype isEqualToString:@"Screen"] &&
       [container isKindOfClass:[KMLScreenOverlay class]]){
        [overlays addObject:container];
        return;
    }
    if(![container isKindOfClass:[KMLAbstractContainer class]]){
        return;
    }
    for(NSObject *feature0 in container.features){
        if([feature0 isKindOfClass:[KMLFolder class]]){
            [self getOverlay:(KMLAbstractContainer *)feature0 type:deftype];
        }
        else{
            if([deftype isEqualToString:@"Ground"]){
                if([feature0 isKindOfClass:[KMLGroundOverlay class]]){
                    [overlays addObject:feature0];
                }
            }
            else if([deftype isEqualToString:@"Screen"]){
                if([feature0 isKindOfClass:[KMLScreenOverlay class]]){
                    [overlays addObject:feature0];
                }
            }
        }
    }
}

//find networklink elements under AbstractContainer
- (void)getNetworklinks:(KMLAbstractContainer *)container
{
    if([container isKindOfClass:[KMLNetworkLink class]]){
        [networklinks addObject:container];
        return;
    }
    if(![container isKindOfClass:[KMLAbstractContainer class]]){
        return;
    }
    for(NSObject *feature0 in container.features){
        if([feature0 isKindOfClass:[KMLFolder class]]){
            [self getNetworklinks:(KMLAbstractContainer *)feature0];
        }
        else if([feature0 isKindOfClass:[KMLNetworkLink class]]){
            [networklinks addObject:feature0];
        }
    }
}

//downloading networklinks recursively
-(void)loadnetworklinks
{
    NSError *error;
    NSString *text;
    networklinks = [NSMutableArray array];
    text = [self getText:error];
    if(text == nil){
        return;
    }
    //parsing kml
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    //get Networklink element
    KMLAbstractContainer *container = (KMLAbstractContainer *)(root.feature);
    //get networklink elements
    [self getNetworklinks:container];
    //for each networklink elements, generate child wg_kml class and download linked file
    for(NSObject *aobj in networklinks){
        KMLNetworkLink *nlink = (KMLNetworkLink *)aobj;
        if(texlab != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                //renew progress
                texlab.text = [NSString stringWithFormat:@"download from %@",nlink.link.href];
            });
        }
        if(nlink.link.href != nil){
            //if kml links local file in kmz
            if(![[nlink.link.href substringToIndex:7] isEqualToString:@"http://"] && kmzflag){
                WG_KML *child = [[WG_KML alloc] initChild:false child:childKml styled:styles];
                child.filePath = [kmzDir stringByAppendingString:nlink.link.href];
                [child loadnetworklinks];
                child.theViewC = _theViewC;
                [self addChild:child];
            }
            else if(![[nlink.link.href substringToIndex:8] isEqualToString:@"https://"] && kmzflag){
                WG_KML *child = [[WG_KML alloc] initChild:false child:childKml styled:styles];
                child.filePath = [kmzDir stringByAppendingString:nlink.link.href];
                [child loadnetworklinks];
                child.theViewC = _theViewC;
                [self addChild:child];
            }
            //if kml links files on the Internet
            else{
                WG_KML *child = [[WG_KML alloc] initChild:false child:childKml styled:styles];
                [child download:nlink.link.href];
                [child loadnetworklinks];
                child.theViewC = _theViewC;
                [self addChild:child];
            }
        }
    }
}

//download file(kml or kmz) from the Internet based on input url
- (int)download:(NSString *)surl
{
    NSString *downfile;
    downfile = [[surl MD5Hash] stringByAppendingString:@".kmx"];//kml or kmz
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];//download path
    NSString *fPath = [[dPath stringByAppendingPathComponent:downfile] stringByStandardizingPath];//full path
    //to avoid hash collision
    int p = 0;
    while([fm fileExistsAtPath:fPath]){
        downfile = [[[surl stringByAppendingString:
                     [NSString stringWithFormat:@"%d", p]] MD5Hash]
                    stringByAppendingString:@".kmx"];
        dPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
        fPath = [[dPath stringByAppendingPathComponent:downfile] stringByStandardizingPath];
        p += 1;
    }
    //download data
    NSURL *url = [NSURL URLWithString:surl];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLResponse *res = nil;
    NSError *err = nil;
    NSData *data = [
                    NSURLConnection
                    sendSynchronousRequest : req
                    returningResponse : &res
                    error : &err
                    ];
    NSString *err_str = [err localizedDescription];
    if (0<[err_str length]) {
        return -1;
    }
    [fm createFileAtPath:fPath contents:[NSData data] attributes:nil];
    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:fPath];
    [file writeData:data];
    _filePath = [NSString stringWithString:fPath];//set file path to download path
    //check if downloaded file is kmz or kml
    NSError *error;
    NSString *text = [[NSString alloc] initWithContentsOfFile:_filePath
                                                     encoding:NSUTF8StringEncoding error:&error];
    if([error localizedDescription].length > 0){//maybe kmz (because not plain text file)
        if([self loadkmz] != 0){//fail to unzip
            return -1;//not kmz and not kml
        }
    }
    else if([text rangeOfString:@"<?xml"].location == NSNotFound ||
       [text rangeOfString:@"<kml"].location == NSNotFound){//plain text but not xml(kml)
        return -1;
    }
    return 0;//load successfully
}
//remove all objects in one wg_kml instance
-(void)removeall_singlekml
{
    [_theViewC removeObjects:mOjects];
    [mOjects removeAllObjects];
}
//remove all objects
-(void)removeall
{
    if(root_flag){
        for(WG_KML *wg_kml_child in childKml){
            [wg_kml_child removeall_singlekml];
        }
    }
}
//load image from local file path or from the Internet
-(UIImage *)load_img:(NSString *)href_url
{
    UIImage *img;
    if([[href_url substringToIndex:7] isEqualToString:@"http://"]){
        img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:href_url]]];
    }
    else if([[href_url substringToIndex:8] isEqualToString:@"https://"]){
        img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:href_url]]];
    }
    else if(kmzflag){//load from local file
        NSString *filepath = [kmzDir stringByAppendingString:href_url];
        img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:filepath]];
    }
    else{
        img = nil;
    }
    return img;
}

//Load all Styles from StyleSelector to StyleContainer
-(WG_KMLStyleContainer *)getStyles:(NSMutableDictionary *)styled styleselector:(NSArray *)stylesl{
    WG_KMLStyleContainer *defaultstyle = nil;
    if(![stylesl isKindOfClass:[NSArray class]]){
        return nil;
    }
    for (NSObject *substyle in stylesl){
        if([substyle isKindOfClass:[KMLStyle class]]){
            WG_KMLStyleContainer *tempstyle = [[WG_KMLStyleContainer alloc] init];
            [tempstyle setStyles:(KMLStyle *)substyle];
            if(((KMLStyle *)substyle).objectID == nil){
                [defaultstyle setStyles:(KMLStyle *)substyle];
            }
            else if([((KMLStyle *)substyle).objectID rangeOfString:@"http://"].location == NSNotFound &&
               [((KMLStyle *)substyle).objectID rangeOfString:@"https://"].location == NSNotFound){
                [styled setObject:tempstyle forKey:
                 [NSString stringWithFormat:@"#%@",((KMLStyle *)substyle).objectID]];
            }
            else{
                [styled setObject:tempstyle forKey:((KMLStyle *)substyle).objectID];
            }
        }
    }
    return defaultstyle;
}

-(void)addChild:(WG_KML *)wg_kml_child
{
    [childKml addObject:wg_kml_child];
}

//load text from file. if not read correctly, return nil
-(NSString *)getText:(NSError *)err{
    NSString *temp;
    if(kmzflag && kmzmainkml != nil){
        temp = [[NSString alloc] initWithContentsOfFile:kmzmainkml encoding:NSUTF8StringEncoding error:&err];
    }
    else if (_filePath != nil){
        temp = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&err];
    }
    else{
        return nil;
    }
    if([err localizedDescription].length > 0){
        return nil;
    }
    if(temp == nil){
        return nil;
    }
    return temp;
}

-(WG_KMLStyleContainer *)setStyle:(KMLPlacemark *)lplace{
    //set styles
    WG_KMLStyleContainer *pstyle = nil;
    if(lplace.styleUrl == nil || lplace.styleUrl == nil){
        pstyle = nil;
    }
    else if([lplace.styleUrl rangeOfString:@"http://"].location == NSNotFound &&
            [lplace.styleUrl rangeOfString:@"https://"].location == NSNotFound){
        if([lplace.styleUrl rangeOfString:@"#"].location != NSNotFound){
            if([[lplace.styleUrl substringToIndex:1] isEqualToString:@"#"]){
                pstyle = [styles objectForKey:lplace.styleUrl];
            }
            else if (kmzflag){
                [self getLocalStyle:lplace.styleUrl];
            }
        }
        else{
            pstyle = [styles objectForKey:
                      [NSString stringWithFormat:@"#%@",lplace.styleUrl]];
        }
    }
    else{//for url like "http://foo.bar/foo.kml#objid"
        NSArray *str_ary = [lplace.styleUrl componentsSeparatedByString:@"#"];
        if(str_ary.count == 2){
            WG_KML *temp_wg = [[WG_KML alloc] init];
            [temp_wg download:str_ary[0]];
            NSError *error;
            NSString *text;
            NSString *objid = [NSString stringWithFormat:@"#%@",str_ary[1]];
            text = [temp_wg getText:error];
            if(text == nil){
                return nil;
            }
            //parsing kml
            KMLRoot *root = [KMLParser parseKMLWithString:text];
            NSArray *stylesl = root.feature.styleSelectors;
            if(![stylesl isKindOfClass:[NSArray class]]){
                return nil;
            }
            for (NSObject *substyle in stylesl){
                if([substyle isKindOfClass:[KMLStyle class]]){
                    if([((KMLStyle *)substyle).objectID isEqualToString:objid]){
                        WG_KMLStyleContainer *tempstyle = [[WG_KMLStyleContainer alloc] init];
                        [tempstyle setStyles:(KMLStyle *)substyle];
                        return tempstyle;
                    }
                    else{
                        continue;
                    }
                }
            }
        }
        else{
            pstyle = nil;
        }
    }
    return pstyle;
}
//load style from local file
-(WG_KMLStyleContainer *)getLocalStyle:(NSString *)localurl{
    WG_KML *l_wg_kml = [[WG_KML alloc] init];
    NSError *error;
    NSString *text;
    
    NSArray *str_ary = [localurl componentsSeparatedByString:@"#"];
    NSString *filename = str_ary[0];
    NSString *objid = [NSString stringWithFormat:@"#%@",str_ary[1]];
    l_wg_kml.filePath = [kmzDir stringByAppendingString:filename];
    text = [l_wg_kml getText:error];
    if(text == nil){
        return nil;
    }
    //parsing kml
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    NSArray *stylesl = root.feature.styleSelectors;
    if(![stylesl isKindOfClass:[NSArray class]]){
        return nil;
    }
    for (NSObject *substyle in stylesl){
        if([substyle isKindOfClass:[KMLStyle class]]){
            if([((KMLStyle *)substyle).objectID isEqualToString:objid]){
                WG_KMLStyleContainer *tempstyle = [[WG_KMLStyleContainer alloc] init];
                [tempstyle setStyles:(KMLStyle *)substyle];
                return tempstyle;
            }
            else{
                continue;
            }
        }
    }
    return nil;
}
-(void)clearChildren{
    [childKml removeAllObjects];
}
@end
