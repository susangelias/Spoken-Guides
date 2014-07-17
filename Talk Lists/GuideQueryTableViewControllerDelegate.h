//
//  GuideQueryTableViewControllerDelegate.h
//  Talk Lists
//
//  Created by Susan Elias on 7/14/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GuideQueryTableViewControllerDelegate <NSObject>

@optional

-(void)rowSelectedAtIndex:(int)index;

@end
