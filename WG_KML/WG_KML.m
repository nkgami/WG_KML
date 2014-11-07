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

@implementation WG_KML
bool kmzflag = false;
NSString *kmzDir;
NSString *kmzmainkml;
NSMutableArray *overlays;
-(void)loadicons
{
    NSMutableDictionary *styles = [NSMutableDictionary dictionary];
    NSMutableDictionary *iconcache = [NSMutableDictionary dictionary];
    NSError *error;
    NSString *text;
    if(kmzflag){
        text = [[NSString alloc] initWithContentsOfFile:kmzmainkml encoding:NSUTF8StringEncoding error:&error];
    }
    else{
        text = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    }
    
    //parsing kml
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    //get style property for each style objectID
    for (NSObject *substyle in root.feature.styleSelectors){
        if([substyle isKindOfClass:[KMLStyle class]]){
            WG_KMLStyleContainer *tempstyle = [[WG_KMLStyleContainer alloc] init];
            [tempstyle setStyles:(KMLStyle *)substyle];
            if([((KMLStyle *)substyle).objectID rangeOfString:@"http://"].location == NSNotFound &&
               [((KMLStyle *)substyle).objectID rangeOfString:@"https://"].location == NSNotFound){
                [styles setObject:tempstyle forKey:
                 [NSString stringWithFormat:@"#%@",((KMLStyle *)substyle).objectID]];
            }
            else{
                [styles setObject:tempstyle forKey:((KMLStyle *)substyle).objectID];
            }
        }
    }
    
    //load each placemark
    NSArray *placemarks = [root placemarks];
    for (id object in placemarks) {
        KMLPlacemark *place = object;
        float latitude = 0,longitude = 0, altitude = 0;

        //set styles
        WG_KMLStyleContainer *pstyle;
        if([place.styleUrl rangeOfString:@"http://"].location == NSNotFound &&
           [place.styleUrl rangeOfString:@"https://"].location == NSNotFound){
            if(![[place.styleUrl substringToIndex:1] isEqualToString:@"#"]){
                pstyle = [styles objectForKey:
                          [NSString stringWithFormat:@"#%@",place.styleUrl]];
                
            }
            else{
                pstyle = [styles objectForKey:place.styleUrl];
            }
        }
        else{
            //load from URL
            //need another logic
        }
        float iconscale;
        NSString *pngpath;
        NSString *color;
        if(pstyle.icon.scale != 0){
            iconscale = pstyle.icon.scale;
        }
        else{
            iconscale = 1;
        }
        if(pstyle.icon.icon.href != nil){
            pngpath = pstyle.icon.icon.href;
        }
        else{
            pngpath = @"http://maps.google.com/mapfiles/kml/paddle/red-circle.png";
        }
        if(pstyle.icon.color != nil){
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
            pngImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pngpath]]];
            if(pngImage != nil){
                [iconcache setObject:pngImage forKey:pngpath];
            }
        }
        else{
            pngImage = (UIImage *)[iconcache objectForKey:pngpath];
        }
        if([place.geometry isKindOfClass:[KMLMultiGeometry class]]){
            for ( KMLAbstractGeometry *x in ((KMLMultiGeometry *)place.geometry).geometries ) {
                latitude = ((KMLPoint *)x).coordinate.latitude;
                longitude = ((KMLPoint *)x).coordinate.longitude;
                altitude = ((KMLPoint *)x).coordinate.altitude;
            }
        }
        else{
            latitude = ((KMLPoint *)place.geometry).coordinate.latitude;
            longitude = ((KMLPoint *)place.geometry).coordinate.longitude;
            altitude = ((KMLPoint *)place.geometry).coordinate.altitude;
        }
        // Create a Screen Marker
        MaplyScreenMarker *marker_p = [[MaplyScreenMarker alloc] init];
        marker_p.loc = MaplyCoordinateMakeWithDegrees(longitude, latitude);
        marker_p.image = pngImage;
        marker_p.size = CGSizeMake(20 * iconscale,20 * iconscale);
        marker_p.layoutImportance = MAXFLOAT;
        marker_p.userObject = place.name;
        if(color != nil){
            ColorConverter *cv = [[ColorConverter alloc] init];
            [cv set_str:color];
            marker_p.color = [UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]];
        }
        marker_p.selectable = YES;
        [_theViewC addScreenMarkers:@[marker_p] desc:nil mode:MaplyThreadAny];
    }
}
-(void)loadpolys
{
    NSMutableDictionary *styles = [NSMutableDictionary dictionary];
    NSError *error;
    NSString *text;
    if(kmzflag){
        text = [[NSString alloc] initWithContentsOfFile:kmzmainkml encoding:NSUTF8StringEncoding error:&error];
    }
    else{
        text = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    }
    //parsing kml
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    //get style property for each style objectID
    for (NSObject *substyle in root.feature.styleSelectors){
        if([substyle isKindOfClass:[KMLStyle class]]){
            WG_KMLStyleContainer *tempstyle = [[WG_KMLStyleContainer alloc] init];
            [tempstyle setStyles:(KMLStyle *)substyle];
            if([((KMLStyle *)substyle).objectID rangeOfString:@"http://"].location == NSNotFound &&
               [((KMLStyle *)substyle).objectID rangeOfString:@"https://"].location == NSNotFound){
                [styles setObject:tempstyle forKey:
                 [NSString stringWithFormat:@"#%@",((KMLStyle *)substyle).objectID]];
            }
            else{
                [styles setObject:tempstyle forKey:((KMLStyle *)substyle).objectID];
            }
        }
    }
    
    //load each placemark
    NSArray *placemarks = [root placemarks];
    for (id object in placemarks) {
        KMLPlacemark *place = object;
        //set styles
        WG_KMLStyleContainer *pstyle;
        if([place.styleUrl rangeOfString:@"http://"].location == NSNotFound &&
           [place.styleUrl rangeOfString:@"https://"].location == NSNotFound){
            if(![[place.styleUrl substringToIndex:1] isEqualToString:@"#"]){
                pstyle = [styles objectForKey:
                          [NSString stringWithFormat:@"#%@",place.styleUrl]];
                
            }
            else{
                pstyle = [styles objectForKey:place.styleUrl];
            }
        }
        else{
            //load from URL
            //need another logic
        }
        NSString *color;
        if(pstyle.poly.color != nil){
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
                    if(color != nil){
                        
                        ColorConverter *cv = [[ColorConverter alloc] init];
                        [cv set_str:color];
                        UIColor *cl = [UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]];
                        [_theViewC addVectors:@[sfOutline] desc:@{kMaplyColor: cl,
                                                         kMaplyFilled:@YES}];
                        //[_theViewC addLoftedPolys:@[sfOutline] key:nil cache:nil desc:@{kMaplyColor: cl,kMaplyLoftedPolyHeight:@0.002}];
                    }
                    else{
                        [_theViewC addVectors:@[sfOutline] desc:@{kMaplyFilled:@YES}];
                        //[_theViewC addLoftedPolys:@[sfOutline] key:nil cache:nil desc:@{kMaplyLoftedPolyHeight:@0.002}];
                    }
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
            if(color != nil){
                
                ColorConverter *cv = [[ColorConverter alloc] init];
                [cv set_str:color];
                UIColor *cl = [UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]];
                [_theViewC addVectors:@[sfOutline] desc:@{kMaplyColor: cl,
                                                          kMaplyFilled:@YES}];
                //[_theViewC addLoftedPolys:@[sfOutline] key:nil cache:nil desc:@{kMaplyColor: cl,kMaplyLoftedPolyHeight:@0.002}];
            }
            else{
                [_theViewC addVectors:@[sfOutline] desc:@{kMaplyFilled:@YES}];
                //[_theViewC addLoftedPolys:@[sfOutline] key:nil cache:nil desc:@{kMaplyLoftedPolyHeight:@0.002}];
            }

        }
    }
}
-(void)loadlines
{
    NSMutableDictionary *styles = [NSMutableDictionary dictionary];
    NSError *error;
    NSString *text;
    if(kmzflag){
        text = [[NSString alloc] initWithContentsOfFile:kmzmainkml encoding:NSUTF8StringEncoding error:&error];
    }
    else{
        text = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    }
    //parsing kml
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    //get style property for each style objectID
    for (NSObject *substyle in root.feature.styleSelectors){
        if([substyle isKindOfClass:[KMLStyle class]]){
            WG_KMLStyleContainer *tempstyle = [[WG_KMLStyleContainer alloc] init];
            [tempstyle setStyles:(KMLStyle *)substyle];
            if([((KMLStyle *)substyle).objectID rangeOfString:@"http://"].location == NSNotFound &&
               [((KMLStyle *)substyle).objectID rangeOfString:@"https://"].location == NSNotFound){
                [styles setObject:tempstyle forKey:
                 [NSString stringWithFormat:@"#%@",((KMLStyle *)substyle).objectID]];
            }
            else{
                [styles setObject:tempstyle forKey:((KMLStyle *)substyle).objectID];
            }
        }
    }
    
    //load each placemark
    NSArray *placemarks = [root placemarks];
    for (id object in placemarks) {
        KMLPlacemark *place = object;
        //set styles
        WG_KMLStyleContainer *pstyle;
        if([place.styleUrl rangeOfString:@"http://"].location == NSNotFound &&
           [place.styleUrl rangeOfString:@"https://"].location == NSNotFound){
            if(![[place.styleUrl substringToIndex:1] isEqualToString:@"#"]){
                pstyle = [styles objectForKey:
                          [NSString stringWithFormat:@"#%@",place.styleUrl]];
                
            }
            else{
                pstyle = [styles objectForKey:place.styleUrl];
            }
        }
        else{
            //load from URL
            //need another logic
        }
        NSString *color;
        if(pstyle.line.color != nil){
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
                        [_theViewC addVectors:@[sfOutline] desc:@{kMaplyColor: cl,
                                                                  kMaplyFilled:@NO}];
                    }
                    else{
                        [_theViewC addVectors:@[sfOutline] desc:@{kMaplyFilled:@NO}];
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
            if(color != nil){
                
                ColorConverter *cv = [[ColorConverter alloc] init];
                [cv set_str:color];
                UIColor *cl = [UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]];
                [_theViewC addVectors:@[sfOutline] desc:@{kMaplyColor: cl,
                                                          kMaplyFilled:@NO}];
            }
            else{
                [_theViewC addVectors:@[sfOutline] desc:@{kMaplyFilled:@NO}];
            }
        }
    }
}
-(void)loadkmz
{
    NSString *zipPath = _filePath;
    NSString *zipFolder = [@"tmp/" stringByAppendingString:@"unzipkmz"];
    NSString *outDir = [NSHomeDirectory() stringByAppendingPathComponent:zipFolder];
    ZipArchive *zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:zipPath];
    BOOL result = [zip UnzipFileTo:outDir overWrite:true];
    if(result == YES )
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        NSArray *list = [fileManager contentsOfDirectoryAtPath:outDir error:&error];
        for (NSString *path in list) {
            if([[path substringFromIndex:([path length] - 4)] isEqualToString:@".kml"]){
                kmzDir = [NSString stringWithFormat:@"%@/",outDir];
                kmzflag = true;
                kmzmainkml = [kmzDir stringByAppendingString:path];
            }
        }
    }
}
-(void)loadgroundoverlay
{
    NSError *error;
    NSString *text;
    overlays = [NSMutableArray array];
    if(kmzflag){
        text = [[NSString alloc] initWithContentsOfFile:kmzmainkml
                                               encoding:NSUTF8StringEncoding error:&error];
    }
    else{
        text = [[NSString alloc] initWithContentsOfFile:_filePath
                                               encoding:NSUTF8StringEncoding error:&error];
    }
    //parsing kml
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    //get GroundOverlay element
    KMLAbstractContainer *container = (KMLAbstractContainer *)(root.feature);
    [self getOverlay:container type:@"Ground"];
    for(NSObject *aobj in overlays){
        KMLGroundOverlay *goverlay = (KMLGroundOverlay *)aobj;
        CGFloat north, south, east, west;
        north = goverlay.latLonBox.north;
        south = goverlay.latLonBox.south;
        east = goverlay.latLonBox.east;
        west = goverlay.latLonBox.west;
        NSString *imagepath = goverlay.icon.href;
        UIImage *imgImage = [[UIImage alloc]
                             initWithData:[NSData dataWithContentsOfURL:
                                           [NSURL URLWithString:imagepath]]];
        MaplySticker *mstick = [[MaplySticker alloc] init];
        mstick.image = imgImage;
        mstick.ll = MaplyCoordinateMakeWithDegrees(west, south);
        mstick.ur = MaplyCoordinateMakeWithDegrees(east, north);
        [_theViewC addStickers:@[mstick] desc:nil];
    }
}
- (void)getOverlay:(KMLAbstractContainer *)container type:(NSString *)deftype
{
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
- (int)download:(NSString *)surl
{
    NSString *downfile;
    if([[surl substringFromIndex:([surl length] - 4)] isEqualToString:@".kml"]){
        downfile = @"download.kml";
    }
    else if([[surl substringFromIndex:([surl length] - 4)] isEqualToString:@".kmz"]){
        downfile = @"download.kmz";
        kmzflag = true;
    }
    else{
        UIAlertView *alert = [
                              [UIAlertView alloc]
                              initWithTitle : @"RequestError"
                              message : @"please input kml or kmz file."
                              delegate : nil
                              cancelButtonTitle : @"OK"
                              otherButtonTitles : nil
                              ];
        [alert show];
        return -1;
    }
    NSString *dPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSString *fPath = [[dPath stringByAppendingPathComponent:downfile] stringByStandardizingPath];
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
        UIAlertView *alert = [
                              [UIAlertView alloc]
                              initWithTitle : @"RequestError"
                              message : err_str
                              delegate : nil
                              cancelButtonTitle : @"OK"
                              otherButtonTitles : nil
                              ];
        [alert show];
        return -1;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createFileAtPath:fPath contents:[NSData data] attributes:nil];
    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:fPath];
    [file writeData:data];
    _filePath = [NSString stringWithString:fPath];
    if(kmzflag){
        [self loadkmz];
    }
    return 0;
}
@end
