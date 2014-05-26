//
//  Guide+Addendums.m
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Guide+Addendums.h"
#import "Step.h"

@implementation Guide (Addendums)

+(NSString *)entityName
{
    return @"Guide";
}

+(instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:moc];
}


-(NSArray *)sortedSteps
{
    NSSortDescriptor *rankSort = [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES];
    NSArray *sorted;
    if (rankSort) {
        sorted = [self.stepInGuide sortedArrayUsingDescriptors:@[rankSort]];
    }
    return sorted;
}

-(void)deleteStepAtIndex:(NSUInteger)index
{
    // get step object
    Step *stepToBeDeleted = [self stepForRank:index];
    
    // remove step from core data
    if (stepToBeDeleted) {
        [self removeStepInGuideObject:stepToBeDeleted];
        
        // update rank for remaining steps
        [self.stepInGuide enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            Step *thisStep = (Step *)obj;
            int thisStepRank = [thisStep.rank intValue];
            if (thisStepRank > index) {
                thisStepRank -= 1;
                thisStep.rank = [NSNumber numberWithInt:thisStepRank];
            }
        }];
    }
}


-(void)moveStepFromNumber:(NSUInteger)fromIndex toNumber:(NSUInteger)toIndex
{
    int newRank;
    Step *thisStep;
    
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

-(Step *)stepForRank:(NSUInteger)rank
{
    // get step object
    NSPredicate *rankPredicate = [NSPredicate predicateWithFormat:@"rank == %d", rank];
    Step *retrievedStep = [self.stepInGuide filteredSetUsingPredicate:rankPredicate].anyObject;
    return retrievedStep;    
}

@end
