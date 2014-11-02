//
//  OptionsViewController.h
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/20.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {PopulationGrowthRate, NulcearPowerPlants, HydroPowerPlants, WindPowerPlants_DEN, NuclearPowerPlants_JPN, Sea_Level_Trends, RailRoads, SFRainRader} OptionType;

@interface OptionsViewController : UITableViewController

@property (nonatomic) OptionType optionType;

@end
