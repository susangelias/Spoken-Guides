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

-(NSMutableArray *)steps
{
    if (!_steps) {
        _steps = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5; i++) {
            Step *stp = [[Step alloc]init];
            stp.rank = i+1;
            [_steps addObject:stp];
        }
    }
    return _steps;
}

-(NSUInteger)numberOfSteps
{
    return [self.steps count];
}

-(void)deleteStep:(NSUInteger)stepNumber
{
    if (stepNumber < [self.steps count]) {
        //delete step object
        [self.steps removeObjectAtIndex:stepNumber];
    }
}

-(void)moveStepFromNumber: (NSUInteger)fromNumber toNumber: (NSUInteger) newNumber
{
    // copy the moving step
    Step *stepToMove = [self.steps objectAtIndex:fromNumber];
    if (fromNumber > newNumber) {
        // remove the step from the array
        [self.steps removeObject:stepToMove];
        // insert the step in its new position
        [self.steps insertObject:stepToMove atIndex:newNumber];
    }
    else if (fromNumber < newNumber) {
        // insert step in into its new position
        [self.steps insertObject:stepToMove atIndex:newNumber+1];
         // remove the step at the old position
        [self.steps removeObjectAtIndex:fromNumber];
    }
}

-(void)insertStep:(NSUInteger)stepNumber
{
    // create step object
    Step *stepToInsert = [[Step alloc]init];
    
    if (stepToInsert && (stepNumber <= [self.steps count])) {
        [self.steps insertObject:stepToInsert atIndex:stepNumber];
        }
}


@end
