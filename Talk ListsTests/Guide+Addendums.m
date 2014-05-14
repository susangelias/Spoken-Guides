//
//  Guide+Addendums.m
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Guide+Addendums.h"
#import "Step+Addendums.h"

@interface Guide_Addendums : XCTestCase

@property   NSManagedObjectContext *moc;

@end

@implementation Guide_Addendums

- (void)setUp
{
    [super setUp];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GuideModel" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    XCTAssertTrue([psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL] ? YES : NO, @"Should be able to add in-memory store");
    self.moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.moc.persistentStoreCoordinator = psc;
}

- (void)tearDown
{
    self.moc = nil;
    
    [super tearDown];
}

-(void)testGuideInsertionIntoManagedContext
{
    Guide *guideInProgress = [Guide insertNewObjectInManagedObjectContext:self.moc];
    XCTAssertNotNil (guideInProgress, @"Guide object must be created and inserted into core data managed object");
    
}

-(void)testArrayOfStepsOrderedByRankReturned
{
    // create guide and add 3 steps
    Guide *guideInProgress = [Guide insertNewObjectInManagedObjectContext:self.moc];
    Step *stepTest1 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest1.rank = [NSNumber numberWithInteger:3];
    [guideInProgress addStepInGuideObject:stepTest1];
    Step *stepTest2 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest2.rank = [NSNumber numberWithInteger:2];
    [guideInProgress addStepInGuideObject:stepTest2];
    Step *stepTest3 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest3.rank = [NSNumber numberWithInteger:1];
    [guideInProgress addStepInGuideObject:stepTest3];
    
    // Ask for the 3 steps sorted, ascending by rank
    NSArray *sortedSteps = [guideInProgress sortedSteps];
    
    // Rank order check
    if ([sortedSteps count] > 0) {
        XCTAssertEqual(sortedSteps[0], stepTest3, @"stepTest3 has lowest rank; should be first in array");
        XCTAssertEqual(sortedSteps[1], stepTest2, @"stepTest2 has middle rank; should be 2nd in array");
        XCTAssertEqual(sortedSteps[2], stepTest1, @"stepTest1 has highest rank; should be 3rd in array");
    }
    else {
        XCTFail(@"sorted steps was an empty array");
    }
    
}

-(void)testDeleteInvalidStepFromArrayOfStepsFailsSilently
{
    // create guide and add 3 steps
    Guide *guideInProgress = [Guide insertNewObjectInManagedObjectContext:self.moc];
    Step *stepTest1 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest1.rank = [NSNumber numberWithInteger:3];
    [guideInProgress addStepInGuideObject:stepTest1];
    Step *stepTest2 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest2.rank = [NSNumber numberWithInteger:2];
    [guideInProgress addStepInGuideObject:stepTest2];
    Step *stepTest3 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest3.rank = [NSNumber numberWithInteger:1];
    [guideInProgress addStepInGuideObject:stepTest3];
    
    // try to delete a step out of range
    [guideInProgress deleteStepAtIndex:10];
    
    // guide should still have 3 steps
    XCTAssertEqual([guideInProgress.stepInGuide count], 3, @"Should be 3 steps still in guide");
}

-(void)testDeleteValidStepFromArrayOfStepsSucceeds
{
    // create guide and add 3 steps
    Guide *guideInProgress = [Guide insertNewObjectInManagedObjectContext:self.moc];
    Step *stepTest1 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest1.rank = [NSNumber numberWithInteger:1];
    [guideInProgress addStepInGuideObject:stepTest1];
    Step *stepTest2 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest2.rank = [NSNumber numberWithInteger:2];
    [guideInProgress addStepInGuideObject:stepTest2];
    Step *stepTest3 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest3.rank = [NSNumber numberWithInteger:3];
    [guideInProgress addStepInGuideObject:stepTest3];
    
    // try to delete the middle step
    [guideInProgress deleteStepAtIndex:2];
    
    // guide should  have 2 steps left
    XCTAssertEqual([guideInProgress.stepInGuide count], 2, @"Should be 2 steps still in guide");
    
    // remaining steps should have updated ranks
    NSArray *sortedSteps = [guideInProgress sortedSteps];
    
    // Rank order check
    if ([sortedSteps count] > 0) {
        Step *step1 = (Step *)sortedSteps[0];
        Step *step2 = (Step *)sortedSteps[1];
        XCTAssertEqual([step1.rank intValue], 1, @"stepTest1 should be first in array");
        XCTAssertEqual([step2.rank intValue], 2, @"stepTest3 should be 2nd in array");
    }
    else {
        XCTFail(@"sorted steps was an empty array");
    }
    

}

-(void)testMoveStepWithInvalidIndexesFailsSilently
{
    // create guide and add 3 steps
    Guide *guideInProgress = [Guide insertNewObjectInManagedObjectContext:self.moc];
    Step *stepTest1 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest1.rank = [NSNumber numberWithInteger:1];
    [guideInProgress addStepInGuideObject:stepTest1];
    Step *stepTest2 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest2.rank = [NSNumber numberWithInteger:2];
    [guideInProgress addStepInGuideObject:stepTest2];
    Step *stepTest3 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest3.rank = [NSNumber numberWithInteger:3];
    [guideInProgress addStepInGuideObject:stepTest3];
    
    // try to move a step from an invalid index
    [guideInProgress moveStepFromNumber:5 toNumber:2];
    
    // Ask for the 3 steps sorted, ascending by rank
    NSArray *sortedSteps = [guideInProgress sortedSteps];
    
    // Should still have 3 steps in the array
    XCTAssertEqual([sortedSteps count], 3, @"Should still have 3 steps in guide");
    
    // Rank order check
    if ([sortedSteps count] > 0) {
        XCTAssertEqual(sortedSteps[0], stepTest1, @"stepTest1 has lowest rank; should be first in array");
        XCTAssertEqual(sortedSteps[1], stepTest2, @"stepTest2 has middle rank; should be 2nd in array");
        XCTAssertEqual(sortedSteps[2], stepTest3, @"stepTest3 has highest rank; should be 3rd in array");
    }
    else {
        XCTFail(@"sorted steps was an empty array");
    }
    
    // try to move a step to an invalid index
    [guideInProgress moveStepFromNumber:2 toNumber:5];
    
    // Ask for the 3 steps sorted, ascending by rank
    sortedSteps = [guideInProgress sortedSteps];
    
    // Should still have 3 steps in the array
    XCTAssertEqual([sortedSteps count], 3, @"Should still have 3 steps in guide");
    
    // Rank order check
    if ([sortedSteps count] > 0) {
        XCTAssertEqual(sortedSteps[0], stepTest1, @"stepTest1 has lowest rank; should be first in array");
        XCTAssertEqual(sortedSteps[1], stepTest2, @"stepTest2 has middle rank; should be 2nd in array");
        XCTAssertEqual(sortedSteps[2], stepTest3, @"stepTest3 has highest rank; should be 3rd in array");
    }
    else {
        XCTFail(@"sorted steps was an empty array");
    }
 
}

-(void)testMoveStepFromLowIndexToHigherIndexSuccessfully
{
    // create guide and add 4 steps
    Guide *guideInProgress = [Guide insertNewObjectInManagedObjectContext:self.moc];
    Step *stepTest1 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest1.rank = [NSNumber numberWithInteger:1];
    [guideInProgress addStepInGuideObject:stepTest1];
    Step *stepTest2 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest2.rank = [NSNumber numberWithInteger:2];
    [guideInProgress addStepInGuideObject:stepTest2];
    Step *stepTest3 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest3.rank = [NSNumber numberWithInteger:3];
    [guideInProgress addStepInGuideObject:stepTest3];
    Step *stepTest4 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest4.rank = [NSNumber numberWithInteger:4];
    [guideInProgress addStepInGuideObject:stepTest4];
    
    // move step 1 to step 3
    [guideInProgress moveStepFromNumber:1 toNumber:3];
    
    // Ask for the 4 steps sorted, ascending by rank
    NSArray *sortedSteps = [guideInProgress sortedSteps];
    
    // Rank order check
    if ([sortedSteps count] > 0) {
        XCTAssertEqual(sortedSteps[0], stepTest2, @"stepTest2 should be first in array");
        XCTAssertEqual(sortedSteps[1], stepTest3, @"stepTest3 should be 2nd in array");
        XCTAssertEqual(sortedSteps[2], stepTest1, @"stepTest1 should be 3rd in array");
        XCTAssertEqual(sortedSteps[3], stepTest4, @"stepTest4 should still be 4th in array");
    }
    else {
        XCTFail(@"sorted steps was an empty array");
    }

}

-(void)testMoveStepFromHighIndexToLowerIndexSuccessfully
{
    // create guide and add 4 steps
    Guide *guideInProgress = [Guide insertNewObjectInManagedObjectContext:self.moc];
    Step *stepTest1 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest1.rank = [NSNumber numberWithInteger:1];
    [guideInProgress addStepInGuideObject:stepTest1];
    Step *stepTest2 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest2.rank = [NSNumber numberWithInteger:2];
    [guideInProgress addStepInGuideObject:stepTest2];
    Step *stepTest3 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest3.rank = [NSNumber numberWithInteger:3];
    [guideInProgress addStepInGuideObject:stepTest3];
    Step *stepTest4 =[Step insertNewObjectInManagedObjectContext:self.moc];
    stepTest4.rank = [NSNumber numberWithInteger:4];
    [guideInProgress addStepInGuideObject:stepTest4];
    
    // move step 3 to step 1
    [guideInProgress moveStepFromNumber:3 toNumber:1];
    
    // Ask for the 4 steps sorted, ascending by rank
    NSArray *sortedSteps = [guideInProgress sortedSteps];
    
    // Rank order check
    if ([sortedSteps count] > 0) {
        XCTAssertEqual(sortedSteps[0], stepTest3, @"stepTest3 should be first in array");
        XCTAssertEqual(sortedSteps[1], stepTest1, @"stepTest1 should be 2nd in array");
        XCTAssertEqual(sortedSteps[2], stepTest2, @"stepTest2 should be 3rd in array");
        XCTAssertEqual(sortedSteps[3], stepTest4, @"stepTest4 should still be 4th in array");
    }
    else {
        XCTFail(@"sorted steps was an empty array");
    }
    
}


@end
