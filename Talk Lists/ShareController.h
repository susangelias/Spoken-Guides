//
//  ShareController.h
//  Talk Lists
//
//  Created by Susan Elias on 6/16/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Guide.h"

@interface ShareController : NSObject

-(void)shareGuide:(Guide *)CDGuide;
-(void)deleteGuide:(Guide *)CDGuide;

@end
