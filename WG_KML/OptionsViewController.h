//
//  OptionsViewController.h
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/20.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {PopulationGrowthRate_Polygon, NulcearPowerPlants_Icon, HydroPowerPlants_Icon, WindPowerPlants_DEN_Icon, NuclearPowerPlants_JPN_Icon, Sea_Level_Trends_Icon, RailRoads_GBR_UKR_LineString, SFRainRadar_GroundOverlay} OptionType;

@interface OptionsViewController : UITableViewController

@property (nonatomic) OptionType optionType;

@end
