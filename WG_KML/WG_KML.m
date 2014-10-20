//
//  WG_KML.m
//  OpenAcademyTest
//
//  Created by Hiroki Nakagami on 2014/10/17.
//  Copyright (c) 2014年 Hiroki Nakagami. All rights reserved.
//

#import "WG_KML.h"
#import "WhirlyGlobeComponent.h"
#import "KML.h"
#import "ColorConverter.h"

@implementation WG_KML
-(void)loadicons
{
    NSError *error;
    NSString *text = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    NSString *pngpath = root.feature.style.iconStyle.icon.href;
    float iconscale = root.feature.style.iconStyle.scale;
    UIImage *pngImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pngpath]]];
    
    NSArray *placemarks = [root placemarks];
    for (id object in placemarks) {
        KMLPlacemark *place = object;
        float latitude = 0,longitude = 0;
        for ( KMLAbstractGeometry *x in ((KMLMultiGeometry *)place.geometry).geometries ) {
            latitude = ((KMLPoint *)x).coordinate.latitude;
            longitude = ((KMLPoint *)x).coordinate.longitude;
        }
        
        // Create a Screen Marker
        MaplyScreenMarker *marker_p = [[MaplyScreenMarker alloc] init];
        marker_p.loc = MaplyCoordinateMakeWithDegrees(longitude, latitude);
        marker_p.image = pngImage;
        marker_p.size = CGSizeMake(20 * iconscale,20 * iconscale);
        marker_p.layoutImportance = MAXFLOAT;
        marker_p.userObject = place.name;
        marker_p.selectable = YES;
        [_theViewC addScreenMarkers:@[marker_p] desc:nil mode:MaplyThreadAny];
    }
}
-(void)loadpolys
{
    NSError *error;
    NSString *text = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    KMLRoot *root = [KMLParser parseKMLWithString:text];
    NSArray *placemarks = [root placemarks];
    for (id object in placemarks) {
        KMLPlacemark *place = object;
        NSString *color = place.style.polyStyle.color;
        ColorConverter *cv = [[ColorConverter alloc] init];
        NSLog(@"color code:%@",color);
        [cv set_str:color];
        NSLog(@"rgba:%f %f %f %f",[cv get_red],[cv get_green],[cv get_blue],[cv get_alpha]);
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
                NSLog(@"num_coords: %d",i);
                MaplyVectorObject *sfOutline = [[MaplyVectorObject alloc] initWithAreal:coords numCoords:i attributes:nil];
                [_theViewC addVectors:@[sfOutline] desc:@{kMaplyColor: [UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]],
                                                         kMaplyFilled:@YES}];
                [_theViewC addLoftedPolys:@[sfOutline] key:nil cache:nil desc:@{kMaplyColor:[UIColor colorWithRed:[cv get_red] green:[cv get_green] blue:[cv get_blue] alpha:[cv get_alpha]],kMaplyLoftedPolyHeight:@0.002}];
            }
        }
    }
}
@end
