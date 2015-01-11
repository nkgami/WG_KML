//
//  OptionsViewController.h
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/20.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

//Options on the first view. set enum and change numberOfRowsInSection and cellForRowAtIndexPath

#import <UIKit/UIKit.h>

typedef enum {PopulationGrowthRate_Polygon, NulcearPowerPlants_Icon, HydroPowerPlants_Icon, WindPowerPlants_DEN_Icon, NuclearPowerPlants_JPN_Icon, Sea_Level_Trends_Icon, RailRoads_GBR_UKR_LineString, SFRainRadar_GroundOverlay, KMLfromURL} OptionType;

@interface OptionsViewController : UITableViewController

@property (nonatomic) OptionType optionType;

@end
