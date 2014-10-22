//
//  WG_KML.h
//  WG_KML
//
//  Created by Hiroki Nakagami on 2014/10/20.
//  Copyright (c) 2014 Hiroki Nakagami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhirlyGlobeComponent.h"

@interface WG_KML : NSObject
@property NSString *filePath;
@property WhirlyGlobeViewController *theViewC;
-(void)loadicons;
-(void)loadpolys;
@end
