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
#import "ConfigViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    WhirlyGlobeViewController * theViewC;
    MaplyQuadImageTilesLayer * aerialLayer;
    MaplyComponentObject * selectLabelObj;
    NSUserDefaults *ud;
    WG_KML *wg_kml;
    ConfigViewController *configViewC;
    //for loading indicator
    UIActivityIndicatorView *ai;
    UIProgressView *pv;
    UIView *uv;
    UILabel *texlab;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self cleantmp];
    // Do any additional setup after loading the view, typically from a nib.
    configViewC = [[ConfigViewController alloc] initWithNibName:@"ConfigViewController" bundle:nil];
    
    //OptionsViewController *optionsViewC = [[OptionsViewController alloc] initWithNibName: bundle:]
    theViewC = [[WhirlyGlobeViewController alloc] init];
    [self.view addSubview:theViewC.view];
    theViewC.view.frame = self.view.bounds;
    [self addChildViewController:theViewC];
    
    theViewC.delegate = self;
    
    ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *ud_defaults = [NSMutableDictionary dictionary];
    [ud_defaults setObject:@"http://example.org/test.kml" forKey:@"KML_URL"];
    [ud registerDefaults:ud_defaults];
    
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
        case PopulationGrowthRate_Polygon:
            [self fetchPopulationGrowthRate];
            break;
        case NulcearPowerPlants_Icon:
            [self fetchNuclearPowerPlants];
            break;
        case HydroPowerPlants_Icon:
            [self fetchHydroPowerPlants];
            break;
        case WindPowerPlants_DEN_Icon:
            [self fetchWindPowerPlants_DEN];
            break;
        case NuclearPowerPlants_JPN_Icon:
            [self fetchNuclearPowerPlants_JPN];
            break;
        case Sea_Level_Trends_Icon:
            [self fetchSea_Level_Trends];
            break;
        case RailRoads_GBR_UKR_LineString:
            [self fetchRailRoads];
            break;
        case SFRainRadar_GroundOverlay:
            [self fetchSFRainRader];
            break;
        case KMLfromURL:
            [self fetchKMLfromURL];
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) fetchPopulationGrowthRate
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample2" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadpolys];
}

- (void) fetchNuclearPowerPlants
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];
}

- (void) fetchHydroPowerPlants
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample3" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];

}

- (void) fetchWindPowerPlants_DEN
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample4" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];

}

- (void) fetchNuclearPowerPlants_JPN
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample5" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];
}

- (void) fetchSea_Level_Trends
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample6" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];
}

- (void) fetchRailRoads
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample7" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadlines];
}

- (void) fetchSFRainRader
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample8" ofType:@"kmz"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadkmz];
    [wg_kml loadgroundoverlay];
}

- (void) fetchKMLfromURL
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"KMLfromURL"
                                                    message:@"input URL of KML or KMZ file"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = [ud stringForKey:@"KML_URL"];
    [alert show];
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString *inputURL = [[alertView textFieldAtIndex:0] text];
        [ud setObject:inputURL forKey:@"KML_URL"];
        wg_kml = [[WG_KML alloc]init];
        wg_kml.theViewC = theViewC;
        if([wg_kml download:inputURL] == 0){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(showConfig)];
        }
    }
}

- (void)showConfig
{
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad)
    {
        popControl = [[UIPopoverController alloc] initWithContentViewController:configViewC];
        popControl.delegate = self;
        [popControl setPopoverContentSize:CGSizeMake(400.0,4.0/5.0*self.view.bounds.size.height)];
        [popControl presentPopoverFromRect:CGRectMake(0, 0, 10, 10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        configViewC.navigationItem.hidesBackButton = YES;
        configViewC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editDone)];
        [self.navigationController pushViewController:configViewC animated:YES];
    }
}

- (void)editDone
{
    [self.navigationController popToViewController:self animated:YES];
    switch (configViewC.selectedIndex) {
        case 0:
            [self start_activity];
            [self load_icon_bg];
            configViewC.selectedIndex = -1;
            break;
        case 1:
            [self start_activity];
            [self load_lines_bg];
            configViewC.selectedIndex = -1;
            break;
        case 2:
            [self start_activity];
            [self load_polys_bg];
            configViewC.selectedIndex = -1;
            break;
        case 3:
            [self start_activity];
            [self load_groundoverlay_bg];
            configViewC.selectedIndex = -1;
            break;
        case 4:
            [self start_activity];
            [self removeall_bg];
            configViewC.selectedIndex = -1;
            break;
        default:
            break;
    }
}

#pragma mark - Popover Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.navigationController popToViewController:self animated:YES];
    switch (configViewC.selectedIndex) {
        case 0:
            [self start_activity];
            [self load_icon_bg];
            configViewC.selectedIndex = -1;
            break;
        case 1:
            [self start_activity];
            [self load_lines_bg];
            configViewC.selectedIndex = -1;
            break;
        case 2:
            [self start_activity];
            [self load_polys_bg];
            configViewC.selectedIndex = -1;
            break;
        case 3:
            [self start_activity];
            [self load_groundoverlay_bg];
            configViewC.selectedIndex = -1;
            break;
        case 4:
            [self start_activity];
            [self removeall_bg];
            configViewC.selectedIndex = -1;
            break;
        default:
            break;
    }
}

-(void)cleantmp
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSError *error;
    NSArray *list = [fm contentsOfDirectoryAtPath:dPath error:&error];
    for (NSString *path in list) {
        NSString *fPath = [[dPath stringByAppendingString:@"/"]
                           stringByAppendingString:path];
        [fm removeItemAtPath:fPath error:&error];
    }
}

-(void)start_activity
{
    uv = [[UIView alloc] initWithFrame:CGRectMake(0,0,250,100)];
    ai = [[UIActivityIndicatorView alloc] init];
    ai.frame = CGRectMake(100, 0, 50, 50);
    ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    pv = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    pv.frame = CGRectMake(25, 95, 200, 10);
    pv.progress = 0;
    texlab = [[UILabel alloc] initWithFrame:CGRectMake(5,50,240,45)];
    texlab.text = @"Now loading";
    texlab.numberOfLines = 0;
    texlab.font = [UIFont systemFontOfSize:12];
    texlab.textAlignment = NSTextAlignmentCenter;
    uv.center = self.view.center;
    uv.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
    uv.userInteractionEnabled = false;
    [wg_kml setProgressView:pv];
    [wg_kml setProgressLabel:texlab];
    [uv addSubview:pv];
    [uv addSubview:ai];
    [uv addSubview:texlab];
    [self.view addSubview:uv];
    [ai startAnimating];
}
-(void) stop_activity{
    [pv removeFromSuperview];
    [ai removeFromSuperview];
    [texlab removeFromSuperview];
    [uv removeFromSuperview];
}
-(void)load_icon_bg{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [wg_kml loadnetworklinks];
        [wg_kml loadicons];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stop_activity];
        });
    });
}
-(void)load_lines_bg{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [wg_kml loadnetworklinks];
        [wg_kml loadlines];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stop_activity];
        });
    });
}
-(void)load_polys_bg{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [wg_kml loadnetworklinks];
        [wg_kml loadpolys];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stop_activity];
        });
    });
}
-(void)load_groundoverlay_bg{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [wg_kml loadnetworklinks];
        [wg_kml loadgroundoverlay];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stop_activity];
        });
    });
}
-(void)removeall_bg{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [wg_kml removeall];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stop_activity];
        });
    });
}
@end
