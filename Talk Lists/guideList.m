//
//  guideList.m
//  Talk Lists
//
//  Created by Susan Elias on 4/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "guideList.h"

@implementation guideList

-(NSArray *)guides
{
        if (!_guides)
        {
            _guides = [@[@"Whatever Guide", @"Making Breakfast Guide", @"Awesome Guide", @"Short Guide"] mutableCopy];
        }
    return _guides;
}

@end
