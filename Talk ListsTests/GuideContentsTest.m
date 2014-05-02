//
//  GuideContentsTest.m
//  Talk Lists
//
//  Created by Susan Elias on 5/2/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GuideContents.h"

@interface GuideContentsTest : XCTestCase

@property (nonatomic, strong) GuideContents *guide;

@end

@implementation GuideContentsTest

- (void)setUp
{
    [super setUp];
    
    self.guide = [[GuideContents alloc] init];
    // setup dummy steps
    self.guide.steps = [@[@"step A", @"step B", @"step C"] mutableCopy];

}

- (void)tearDown
{
    self.guide = nil;
    [super tearDown];
}

-(void)testGuideContentsObjectExists
{
    XCTAssertNotNil(self.guide, @"guide content object must exist");
}

-(void)testGuideStepIsDeleted
{
     // delete step B
    [self.guide deleteStep:1];
    
    XCTAssertEqual([self.guide.steps count], 2, @"should only have 2 steps after deletion");
    XCTAssertEqual(self.guide.steps[0], @"step A", @"step A should still be in the guide");
    XCTAssertEqual(self.guide.steps[1], @"step C", @"step C should still be in the guide");
}

-(void)testGuideStepIsMovedFromEndToBeginning
{
    // move step C to beginning
    [self.guide moveStepFromNumber:2 toNumber:0];
    
    XCTAssertEqual([self.guide.steps count], 3, @"should still have 3 steps after move");
    XCTAssertEqual(self.guide.steps[0], @"step C", @"step C should be in position 1");
    XCTAssertEqual(self.guide.steps[1], @"step A", @"step A should be in position 2");
    XCTAssertEqual(self.guide.steps[2], @"step B", @"step B should be in position 3");

}

-(void)testGuideStepIsMovedFromBeginningToEnd
{
 
    // move step A to end
    [self.guide moveStepFromNumber:0 toNumber:2];
    
    XCTAssertEqual([self.guide.steps count], 3, @"should still have 3 steps after move");
    XCTAssertEqual(self.guide.steps[0], @"step B", @"step B should be in position 1");
    XCTAssertEqual(self.guide.steps[1], @"step C", @"step V should be in position 2");
    XCTAssertEqual(self.guide.steps[2], @"step A", @"step B should be in position 3");
    
}

-(void)testGuideStepIsInsertedAtBeginning
{
    NSUInteger currentStepCount = [self.guide.steps count];
    NSUInteger index = 0;
    [self.guide insertStep:index];
    XCTAssertEqual(currentStepCount+1, [self.guide.steps count], @"number of steps should increase by 1");
    XCTAssertEqual(self.guide.steps[1], @"step A", @"step B should be in position 2");
    XCTAssertEqual(self.guide.steps[2], @"step B", @"step B should be in position 3");
    XCTAssertEqual(self.guide.steps[3], @"step C", @"step C should be in position 4");
}

-(void)testGuideStepIsInsertedAtEnd
{
    NSUInteger currentStepCount = [self.guide.steps count];
    NSUInteger index = [self.guide.steps count];
    [self.guide insertStep:index];
    XCTAssertEqual(currentStepCount+1, [self.guide.steps count], @"number of steps should increase by 1");
    XCTAssertEqual(self.guide.steps[0], @"step A", @"step B should be in position 1");
    XCTAssertEqual(self.guide.steps[1], @"step B", @"step B should be in position 2");
    XCTAssertEqual(self.guide.steps[2], @"step C", @"step C should be in position 3");
    XCTAssertNotNil(self.guide.steps[3], @"new step should be in position 4");

}

-(void)testGuideStepIsInsertedInMiddle
{
    NSUInteger currentStepCount = [self.guide.steps count];
   
    [self.guide insertStep:2];
    XCTAssertEqual(currentStepCount+1, [self.guide.steps count], @"number of steps should increase by 1");
    XCTAssertEqual(self.guide.steps[0], @"step A", @"step B should be in position 1");
    XCTAssertEqual(self.guide.steps[1], @"step B", @"step B should be in position 2");
    XCTAssertNotNil(self.guide.steps[2], @"new step should be in position 3");
    XCTAssertEqual(self.guide.steps[3], @"step C", @"step C should be in position 4");
    
}

@end
