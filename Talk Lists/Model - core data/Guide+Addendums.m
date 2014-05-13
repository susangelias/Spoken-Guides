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
    NSPredicate *rankPredicate = [NSPredicate predicateWithFormat:@"rank == %d", index];
    Step *stepToBeDeleted = [self.stepInGuide filteredSetUsingPredicate:rankPredicate].anyObject;
    
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

@end
