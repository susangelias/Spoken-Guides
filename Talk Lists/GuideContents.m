//
//  GuideContents.m
//  Talk Lists
//
//  Created by Susan Elias on 4/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideContents.h"
#import "Step.h"

@implementation GuideContents

-(NSArray *)steps
{
    if (!_steps) {
        NSMutableArray *tempSteps = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5; i++) {
            Step *stp = [[Step alloc]init];
            [tempSteps addObject:stp];
        }
        _steps = [tempSteps copy];
    }
    return _steps;
}

-(NSUInteger)numberOfSteps
{
    return [self.steps count];
}

@end
