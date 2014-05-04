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
@property (nonatomic, strong) Step *step1;
@property (nonatomic, strong) Step *step2;
@property (nonatomic, strong) Step *step3;

@end

@implementation GuideContentsTest

- (void)setUp
{
    [super setUp];
    
    self.guide = [[GuideContents alloc] init];
    // setup dummy steps
    self.step1 = [[Step alloc]init];
    self.step1.instruction = @"step A";
    self.step1.photo = [UIImage imageNamed:@"cooking"];
    self.step2 = [[Step alloc]init];
    self.step2.instruction = @"step B";
    self.step3 = [[Step alloc]init];
    self.step3.instruction = @"step C";
    self.guide.steps = [@[self.step1, self.step2, self.step3] mutableCopy];

}

- (void)tearDown
{
    self.step1 = nil;
    self.step2 = nil;
    self.step3 = nil;
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
    XCTAssertEqual(self.guide.steps[0], self.step1, @"step 1 should still be in the guide");
    XCTAssertEqual(self.guide.steps[1], self.step3, @"step 3 should still be in the guide");
}

-(void)testFirstStepIsInserted
{
    // remove the steps created in setUp
    self.guide.steps = nil;
    [self.guide insertStep:0 withInstruction:@"instruction text" withPhoto:nil];
    XCTAssertEqual([self.guide.steps count], 1, @"should only have 1 step after initial insertion");
}

-(void)testGuideStepIsMovedFromEndToBeginning
{
    // move step C to beginning
    [self.guide moveStepFromNumber:2 toNumber:0];
    
    XCTAssertEqual([self.guide.steps count], 3, @"should still have 3 steps after move");
    XCTAssertEqual(self.guide.steps[0], self.step3, @"step 3 should be in position 1");
    XCTAssertEqual(self.guide.steps[1], self.step1, @"step 1 should be in position 2");
    XCTAssertEqual(self.guide.steps[2], self.step2, @"step 2 should be in position 3");

}

-(void)testGuideStepIsMovedFromBeginningToEnd
{
 
    // move step A to end
    [self.guide moveStepFromNumber:0 toNumber:2];
    
    XCTAssertEqual([self.guide.steps count], 3, @"should still have 3 steps after move");
    XCTAssertEqual(self.guide.steps[0], self.step2, @"step 2 should be in position 1");
    XCTAssertEqual(self.guide.steps[1], self.step3, @"step 3 should be in position 2");
    XCTAssertEqual(self.guide.steps[2], self.step1, @"step 1 should be in position 3");
    
}

-(void)testGuideStepIsInsertedAtBeginning
{
    NSUInteger currentStepCount = [self.guide.steps count];
    NSUInteger index = 0;
    [self.guide insertStep:index withInstruction:@"instruction text" withPhoto:nil];
    XCTAssertEqual(currentStepCount+1, [self.guide.steps count], @"number of steps should increase by 1");
    XCTAssertEqual(self.guide.steps[1], self.step1, @"step 1 should be in position 2");
    XCTAssertEqual(self.guide.steps[2], self.step2, @"step 2 should be in position 3");
    XCTAssertEqual(self.guide.steps[3], self.step3, @"step 3 should be in position 4");
}

-(void)testGuideStepIsInsertedAtEnd
{
    NSUInteger currentStepCount = [self.guide.steps count];
    NSUInteger index = [self.guide.steps count];
    [self.guide insertStep:index withInstruction:@"instruction text" withPhoto:nil];
    XCTAssertEqual(currentStepCount+1, [self.guide.steps count], @"number of steps should increase by 1");
    XCTAssertEqual(self.guide.steps[0], self.step1, @"step 1 should be in position 1");
    XCTAssertEqual(self.guide.steps[1], self.step2, @"step 2 should be in position 2");
    XCTAssertEqual(self.guide.steps[2], self.step3, @"step 3 should be in position 3");
    XCTAssertNotNil(self.guide.steps[3], @"new step should be in position 4");

}

-(void)testGuideStepIsInsertedInMiddle
{
    NSUInteger currentStepCount = [self.guide.steps count];
   
    [self.guide insertStep:2 withInstruction:@"instruction text" withPhoto:nil];
    XCTAssertEqual(currentStepCount+1, [self.guide.steps count], @"number of steps should increase by 1");
    XCTAssertEqual(self.guide.steps[0], self.step1, @"step 1 should be in position 1");
    XCTAssertEqual(self.guide.steps[1], self.step2, @"step 2 should be in position 2");
    XCTAssertNotNil(self.guide.steps[2], @"new step should be in position 3");
    XCTAssertEqual(self.guide.steps[3], self.step3, @"step 3 should be in position 4");
    
}

-(void)testGuideStepTextIsSetAtStepNumber
{
    [self.guide insertStep:2 withInstruction:@"My Instructions" withPhoto:nil];
    Step *step = self.guide.steps[2];
    XCTAssertEqual(step.instruction, @"My Instructions", @"step instructions must be equal");
}

-(void)testGuideStepInsertedWithoutTextOrPhotoDoesNothing
{
    NSUInteger guideStepCount = [self.guide.steps count];
    [self.guide insertStep:2 withInstruction:nil withPhoto:nil];
    XCTAssertEqual([self.guide.steps count], guideStepCount, @"No step should have been inserted");
}

-(void)testGuideStepPhotoIsSetAtStepNumber
{
    [self.guide insertStep:2 withInstruction:nil withPhoto:[UIImage imageNamed:@"Cooking"]];
    Step *step = self.guide.steps[2];
    XCTAssertEqual(step.photo, [UIImage imageNamed:@"Cooking"], @"step photos must be equal");
}

-(void)testReplaceInstructionInExistingStep
{
   Step *step = self.guide.steps[1];
    NSString *existingInstruction = step.instruction;
    [self.guide replaceStepInstruction:@"Edited instruction" atNumber:1];
    XCTAssertNotEqual(step.instruction, existingInstruction, @"instruction must be replaced");
    XCTAssertEqual(step.instruction, @"Edited instruction", @"new instruction must be set");
}

-(void)testReplaceInstructionAtNonexistentStepFails
{
    XCTAssertThrows([self.guide replaceStepInstruction:@"Edited Instruction" atNumber:[self.guide.steps count]+3], @"Attempt to replace instruction at nonexistent step should throw assertion");

}

-(void)testReplacePhotoInExistingStep
{
    Step *step = self.guide.steps[0];
    UIImage *existingPhoto = step.photo;
    UIImage *updatePhoto = [UIImage imageNamed:@"general"];
    [self.guide replaceStepPhoto:updatePhoto atNumber:0];
    XCTAssertNotEqual(step.photo, existingPhoto, @"photo must be replaced");
    XCTAssertEqual(step.photo, updatePhoto, @"new photo must be set");
}

-(void)testReplacePhotoAtNonexistentStepFails
{
    XCTAssertThrows([self.guide replaceStepPhoto:[UIImage imageNamed:@"general"] atNumber:[self.guide.steps count]], @"Attempt to replace photo at nonexistent step should throw assertion");
    
}

@end
