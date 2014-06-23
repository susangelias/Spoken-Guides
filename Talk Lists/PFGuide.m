//
//  PFGuide.m
//  Talk Lists
//
//  Created by Susan Elias on 6/16/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PFGuide.h"
#import <Parse/PFObject+Subclass.h>

@interface PFGuide()

//@property (nonatomic, strong) NSArray *stepsInGuide;

@end

@implementation PFGuide

@dynamic classification;
@dynamic creationDate;
@dynamic modifiedDate;
@dynamic title;
@dynamic uniqueID;
@dynamic photo;
@dynamic steps;
@dynamic numberOfSteps;

@synthesize  stepsInGuide = _stepsInGuide;

+ (NSString *)parseClassName {
    return @"PFGuide";
}


-(NSArray *)sortedSteps
{
    NSSortDescriptor *rankSort = [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES];
    NSArray *sorted;
    if (rankSort) {
        sorted = [self.stepsInGuide sortedArrayUsingDescriptors:@[rankSort]];
    }
    return sorted;
}

-(void)deleteStepAtIndex:(NSUInteger)index
{
    // get step object
    PFStep *stepToBeDeleted = [self stepForRank:index];
    
    // remove step from core data
    /*
    if (stepToBeDeleted) {
        [self removeStepInGuideObject:stepToBeDeleted];
        
        // update rank for remaining steps
        [self.stepsInGuide enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            PFStep *thisStep = (PFStep *)obj;
            int thisStepRank = [thisStep.rank intValue];
            if (thisStepRank > index) {
                thisStepRank -= 1;
                thisStep.rank = [NSNumber numberWithInt:thisStepRank];
            }
        }];
    }
     */
}


-(void)moveStepFromNumber:(NSUInteger)fromIndex toNumber:(NSUInteger)toIndex
{
    int newRank;
    PFStep *thisStep;
    
    // get array of steps sorted by rank
    NSMutableArray *rankedSteps = [[self sortedSteps] mutableCopy];
    
    // verify range of indexes
    if ( (fromIndex > [rankedSteps count]) || (toIndex > [rankedSteps count]) ) {
        return;    // do nothing, fail silently
    }
    
    if (fromIndex > toIndex) {
        thisStep = rankedSteps[fromIndex-1];
        thisStep.rank  = [NSNumber numberWithInt:toIndex];
        // re-rank all the steps inbetween
        for (int i = toIndex-1; i < fromIndex-1; i++) {
            thisStep = rankedSteps[i];
            newRank = [thisStep.rank intValue];
            thisStep.rank = [NSNumber numberWithInt:newRank + 1];
        }
        
    }
    else if (fromIndex < toIndex) {
        // re-rank all the steps downstream from the inserting point
        for (int i = fromIndex; i < toIndex; i++) {
            thisStep = rankedSteps[i];
            newRank = [thisStep.rank intValue];
            thisStep.rank = [NSNumber numberWithInt:newRank - 1];
        }
        // update the inserted step's rank
        thisStep = rankedSteps[fromIndex-1];
        thisStep.rank = [NSNumber numberWithInt:toIndex];
    }
}

-(PFStep *)stepForRank:(NSUInteger)rank
{
    // get step object with rank
    __block PFStep *retrievedStep;
    [self.stepsInGuide enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PFStep *step = (PFStep *)obj;
        if (step.rank == [NSNumber numberWithInt:rank]) {
            *stop = YES;
            retrievedStep = step;
        }
    }];
    return retrievedStep;
}

#pragma mark initializers

-(NSArray *)stepsInGuide
{
    if (!_stepsInGuide) {
        _stepsInGuide = [[NSArray alloc] init];
    }
    return _stepsInGuide;
}

-(void)setStepsInGuide:(NSArray *)stepsInGuide
{
    _stepsInGuide = stepsInGuide;
}

@end
