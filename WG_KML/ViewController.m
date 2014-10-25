//
//  ViewController.m
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/20.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import "ViewController.h"
#import "WhirlyGlobeComponent.h"
#import "KML.h"
#import "ColorConverter.h"
#import "OptionsViewController.h"
#import "WG_KML.h"

@interface ViewController ()

@end

@implementation ViewController
{
    WhirlyGlobeViewController * theViewC;
    MaplyQuadImageTilesLayer * aerialLayer;
    MaplyComponentObject * selectLabelObj;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //OptionsViewController *optionsViewC = [[OptionsViewController alloc] initWithNibName: bundle:]
    theViewC = [[WhirlyGlobeViewController alloc] init];
    [self.view addSubview:theViewC.view];
    theViewC.view.frame = self.view.bounds;
    [self addChildViewController:theViewC];
    
    theViewC.delegate = self;
    
    NSString *baseCacheDir = [NSSearchPathForDirectoriesInDomains
                              (NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *aerialTtileCacheDir = [NSString stringWithFormat:@"%@_myTiles/",baseCacheDir];
    int maxZoom = 18;
    //OSM Data
    MaplyRemoteTileSource *tileSource = [[MaplyRemoteTileSource alloc] initWithBaseURL:@"http://otile1.mqcdn.com/tiles/1.0.0/sat/" ext:@"png" minZoom:0 maxZoom:maxZoom];
    tileSource.cacheDir = aerialTtileCacheDir;
    aerialLayer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
    
    
    [theViewC addLayer:aerialLayer];
    
    [theViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-102.416667, 37.783333) time:1.0];
    
    switch (_option)
    {
        case PopulationGrowthRate:
            [self fetchPopulationGrowthRate];
            break;
        case NulcearPowerPlants:
            [self fetchNuclearPowerPlants];
            break;
        case HydroPowerPlants:
            [self fetchHydroPowerPlants];
            break;
        case WindPowerPlants_DEN:
            [self fetchWindPowerPlants_DEN];
            break;
        case NuclearPowerPlants_JPN:
            [self fetchNuclearPowerPlants_JPN];
            break;
        case Sea_Level_Trends:
            [self fetchSea_Level_Trends];
            break;
        case RailRoads:
            [self fetchRailRoads];
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) fetchPopulationGrowthRate
{
    WG_KML *wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample2" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadpolys];
}

- (void) fetchNuclearPowerPlants
{
    WG_KML *wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];

}

- (void) fetchHydroPowerPlants
{
    WG_KML *wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample3" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];

}

- (void) fetchWindPowerPlants_DEN
{
    WG_KML *wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample4" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];

}

- (void) fetchNuclearPowerPlants_JPN
{
    WG_KML *wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample5" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];
}

- (void) fetchSea_Level_Trends
{
    WG_KML *wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample6" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];
}

- (void) fetchRailRoads
{
    WG_KML *wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample7" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadlines];
}

- (void)globeViewController:(WhirlyGlobeViewController *)viewC didSelect:(NSObject *) selectedObj atLoc:(MaplyCoordinate)coord onScreen:(CGPoint)screenPt
{
    if(selectLabelObj){
        [theViewC removeObject:selectLabelObj];
        selectLabelObj = nil;
    }
    
    if([selectedObj isKindOfClass:[MaplyScreenMarker class]])
    {
        MaplyScreenMarker *marker = (MaplyScreenMarker *)selectedObj;
        NSString *title = (NSString *)marker.userObject;
        
        MaplyScreenLabel *label = [[MaplyScreenLabel alloc] init];
        label.loc = coord;
        label.text =title;
        label.selectable = YES;
        selectedObj = [theViewC addScreenLabels:@[label] desc:
                       @{kMaplyFont: [UIFont systemFontOfSize:12.0]}];
    }
}


@end
