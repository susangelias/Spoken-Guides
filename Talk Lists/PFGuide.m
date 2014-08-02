//
//  PFGuide.m
//  Talk Lists
//
//  Created by Susan Elias on 6/16/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PFGuide.h"
#import <Parse/PFObject+Subclass.h>

// Class key
NSString *const kPFGuideClassKey = @"PFGuide";

#pragma mark - Cached PFGuide Attributes
// keys
NSString *const kPFGuideChangedImage = @"changedImage";
NSString *const kPFGuideChangedThumbnail = @"changedThumbnail";

@interface PFGuide()

@end

@implementation PFGuide

@dynamic classification;
@dynamic title;
@dynamic pfSteps;
@dynamic image;
@dynamic thumbnail;
@dynamic user;

@synthesize  rankedStepsInGuide = _rankedStepsInGuide;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}


-(void)deleteStepAtIndex:(NSUInteger)index withCompletionBlock:(deleteCompleteBlock)completionBlock
{
    int rankToDelete = index+1; // steps are ranked 1 to n
    // get step object
    PFStep *stepToBeDeleted = [self stepForRank:rankToDelete];

    // remove step from parse back end
    __weak typeof(self) weakSelf = self;
    [stepToBeDeleted deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // remove step from local array of steps in guide
            [weakSelf.rankedStepsInGuide removeObject:stepToBeDeleted];
          //  weakSelf.numberOfSteps = [NSNumber numberWithInt:[weakSelf.rankedStepsInGuide count]];
          //  [weakSelf saveInBackground];
            NSLog(@"deleted step for a total of %d steps", [weakSelf.rankedStepsInGuide count]);

            if ([weakSelf.rankedStepsInGuide count] > 0) {
                // update rank for remaining steps
                [weakSelf.rankedStepsInGuide enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    PFStep *thisStep = (PFStep *)obj;
                    int thisStepRank = [thisStep.rank intValue];
                    if (thisStepRank > rankToDelete) {
                        thisStepRank -= 1;
                        thisStep.rank = [NSNumber numberWithInt:thisStepRank];
                        [thisStep saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (idx+1 == [weakSelf.rankedStepsInGuide count]) {
                                // have finished re-ranking steps
                                completionBlock();
                            }
                        }];
                    }
                    else if (idx+1 == [weakSelf.rankedStepsInGuide count]) {
                        // last step was deleted so no re-ranking is required
                        completionBlock();
                    }
                }];
            }
            else {
                // all the steps have been deleted
                completionBlock();
            }
        }
    }];
    


}


-(void)moveStepFromNumber:(NSUInteger)fromIndex toNumber:(NSUInteger)toIndex
{
    int newRank;
    PFStep *thisStep;
    
    // get array of steps sorted by rank
    NSMutableArray *rankedSteps = [self.rankedStepsInGuide mutableCopy];
    
    // verify range of indexes
    if ( (fromIndex > [rankedSteps count]) || (toIndex > [rankedSteps count]) ) {
        return;    // do nothing, fail silently
    }
    
    if (fromIndex > toIndex) {
        thisStep = rankedSteps[fromIndex-1];
        thisStep.rank  = [NSNumber numberWithInt:toIndex];
        [thisStep saveInBackground];
        // re-rank all the steps inbetween
        for (int i = toIndex-1; i < fromIndex-1; i++) {
            thisStep = rankedSteps[i];
            newRank = [thisStep.rank intValue];
            thisStep.rank = [NSNumber numberWithInt:newRank + 1];
            [thisStep saveInBackground];
        }
        
    }
    else if (fromIndex < toIndex) {
        // re-rank all the steps downstream from the inserting point
        for (int i = fromIndex; i < toIndex; i++) {
            thisStep = rankedSteps[i];
            newRank = [thisStep.rank intValue];
            thisStep.rank = [NSNumber numberWithInt:newRank - 1];
            [thisStep saveInBackground];
        }
        // update the inserted step's rank
        thisStep = rankedSteps[fromIndex-1];
        thisStep.rank = [NSNumber numberWithInt:toIndex];
        [thisStep saveInBackground];
    }
}

 -(PFStep *)stepForRank:(NSUInteger)rank
{
    // get step object with rank
    __block PFStep *retrievedStep;
    [self.rankedStepsInGuide enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PFStep *step = (PFStep *)obj;
        if (step.rank == [NSNumber numberWithInt:rank]) {
            *stop = YES;
            retrievedStep = step;
        }
    }];
    return retrievedStep;
}



#pragma mark initializers

-(NSMutableArray *)rankedStepsInGuide
{
    if (!_rankedStepsInGuide) {
        _rankedStepsInGuide = [[NSMutableArray alloc] init];
    }
    return _rankedStepsInGuide;
}

-(void)setStepsInGuide:(NSMutableArray *)rankedStepsInGuide
{
    _rankedStepsInGuide = rankedStepsInGuide;
}

@end
