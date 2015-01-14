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
    NSUserDefaults *ud; //save url
    WG_KML *wg_kml; //main class for kml
    ConfigViewController *configViewC; //for download method
    
    //for loading indicator
    UIActivityIndicatorView *ai;
    UIProgressView *pv;
    UIView *uv;
    UILabel *texlab;
    
}

//this method is needed for memory free
- (void)viewWillDisappear:(BOOL)animated
{
    if(![self.navigationController.viewControllers containsObject:self]){
        [wg_kml clearChildren];
        theViewC = nil;
        wg_kml = nil;
        aerialLayer = nil;
        configViewC = nil;
    }
    [super viewWillDisappear:animated];
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
    
    //for default layer(earth ground)
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
    
    //set UserDefaults to save url which user input
    ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *ud_defaults = [NSMutableDictionary dictionary];
    [ud_defaults setObject:@"http://example.org/test.kml" forKey:@"KML_URL"];
    [ud registerDefaults:ud_defaults];
    
    //from user select, switch to each method
    switch (_option)
    {
        case PopulationGrowthRate_Polygon:
            [self fetchPopulationGrowthRate];//load from local kml
            break;
        case NulcearPowerPlants_Icon:
            [self fetchNuclearPowerPlants];//load from local kml
            break;
        case HydroPowerPlants_Icon:
            [self fetchHydroPowerPlants];//load from local kml
            break;
        case WindPowerPlants_DEN_Icon:
            [self fetchWindPowerPlants_DEN];//load from local kml
            break;
        case NuclearPowerPlants_JPN_Icon:
            [self fetchNuclearPowerPlants_JPN];//load from local kml
            break;
        case Sea_Level_Trends_Icon:
            [self fetchSea_Level_Trends];//load from local kml
            break;
        case RailRoads_GBR_UKR_LineString:
            [self fetchRailRoads];//load from local kml
            break;
        case SFRainRadar_GroundOverlay:
            [self fetchSFRainRader];//load from local kmz
            break;
        case KMLfromURL:
            [self fetchKMLfromURL];//download kml using user input url
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Polygon sample
- (void) fetchPopulationGrowthRate
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample2" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadpolys];
}

//Icon sample
- (void) fetchNuclearPowerPlants
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];
}

//Icon sample
- (void) fetchHydroPowerPlants
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample3" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];

}

//Icon sample
- (void) fetchWindPowerPlants_DEN
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample4" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];

}

//Icon sample
- (void) fetchNuclearPowerPlants_JPN
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample5" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];
}

//Icon sample
- (void) fetchSea_Level_Trends
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample6" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadicons];
}

//LineString sample
- (void) fetchRailRoads
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample7" ofType:@"kml"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadlines];
}

//GroundOverlay sample
- (void) fetchSFRainRader
{
    wg_kml = [[WG_KML alloc]init];
    wg_kml.filePath = [[NSBundle mainBundle] pathForResource:@"sample8" ofType:@"kmz"];
    wg_kml.theViewC = theViewC;
    [wg_kml loadkmz];
    [wg_kml loadgroundoverlay];
}

//Networklink and download method sample.You can select which element to show
- (void) fetchKMLfromURL
{
    //show UI to input url
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

//Show name of the icon when touch icons
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

//Download KML from url
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString *inputURL = [[alertView textFieldAtIndex:0] text];
        [ud setObject:inputURL forKey:@"KML_URL"];
        wg_kml = [[WG_KML alloc]init];
        wg_kml.theViewC = theViewC;
        if([wg_kml download:inputURL] == 0){// show configure view
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(showConfig)];
        }
        else{//bad file
            UIAlertView *alert = [
                                  [UIAlertView alloc]
                                  initWithTitle : @"RequestError"
                                  message : @"please input kml or kmz file."
                                  delegate : nil
                                  cancelButtonTitle : @"OK"
                                  otherButtonTitles : nil
                                  ];
            [alert show];
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

//after choosing "Done", load each elements on background.
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

//before start, clean temporary files
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

//show how is the progress of background loading on front view
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

//stop showing the progress
-(void) stop_activity{
    [pv removeFromSuperview];
    [ai removeFromSuperview];
    [texlab removeFromSuperview];
    [uv removeFromSuperview];
}

//Background loading methods
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
