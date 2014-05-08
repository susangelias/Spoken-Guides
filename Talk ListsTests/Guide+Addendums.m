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

@end
