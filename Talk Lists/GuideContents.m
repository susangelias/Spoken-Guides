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

- (NSMutableArray *)steps
{
    // set up dummy data
    if (!_steps) {
        Step *step1 = [[Step alloc]init];
        step1.instruction = @"step A";
        step1.photo = [UIImage imageNamed:@"cooking"];
        Step * step2 = [[Step alloc]init];
        step2.instruction = @"step B";
        Step * step3 = [[Step alloc]init];
        step3.instruction = @"step C";
        _steps = [[NSMutableArray alloc] initWithArray:@[step1, step2, step3]];
    }
    return _steps;
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

-(void)insertStep:(NSUInteger)stepNumber withInstruction: (NSString *)text withPhoto: (UIImage *)photo
{
    // create step object
    Step *stepToInsert = [[Step alloc]init];
    stepToInsert.instruction = text;
    stepToInsert.photo = photo;
    
    if (stepToInsert && (stepNumber <= [self.steps count]) && (text || photo) ) {
        [self.steps insertObject:stepToInsert atIndex:stepNumber];
        }
}

-(void)replaceStepInstruction:(NSString *)stepText atNumber: (NSUInteger)stepNumber
{
    // make sure step exists
    if (stepNumber < [self.steps count]) {
        Step *modifyingStep = self.steps[stepNumber];
        modifyingStep.instruction = stepText;
    }
    else {
        NSParameterAssert(stepNumber < [self.steps count]);
    }
}

-(void)replaceStepPhoto:(UIImage *)stepPhoto atNumber: (NSUInteger)stepNumber
{
    // make sure step exists
    if (stepNumber < [self.steps count]) {
        Step *modifyingStep = self.steps[stepNumber];
        modifyingStep.photo = stepPhoto;
    }
    else {
        NSParameterAssert(stepNumber < [self.steps count]);
    }
}


@end
