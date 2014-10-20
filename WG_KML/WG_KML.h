//
//  WG_KML.h
//  OpenAcademyTest
//
//  Created by Hiroki Nakagami on 2014/10/17.
//  Copyright (c) 2014年 Hiroki Nakagami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhirlyGlobeComponent.h"

@interface WG_KML : NSObject
@property NSString *filePath;
@property WhirlyGlobeViewController *theViewC;
-(void)loadicons;
-(void)loadpolys;
@end
