//
//  ViewController.h
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/20.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhirlyGlobeComponent.h"
#import "OptionsViewController.h"

@interface ViewController : UIViewController <WhirlyGlobeViewControllerDelegate>

@property OptionType option;

@end

