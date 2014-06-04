//
//  EditGuideViewControllerTest.m
//  Talk Lists
//
//  Created by Susan Elias on 6/3/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EditGuideViewController.h"

@interface EditGuideViewControllerTest : XCTestCase
@property   NSManagedObjectContext *moc;
@property EditGuideViewController *editGuideVC;

@end

@implementation EditGuideViewControllerTest

- (void)setUp
{
    [super setUp];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GuideModel" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    XCTAssertTrue([psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL] ? YES : NO, @"Should be able to add in-memory store");
    self.moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.moc.persistentStoreCoordinator = psc;
    
    self.editGuideVC = [[EditGuideViewController alloc] init];
    self.editGuideVC.managedObjectContext = self.moc;
    [self.editGuideVC viewDidLoad];
}

- (void)tearDown
{
    self.moc = nil;
    
    [super tearDown];
}

- (void)testEditGuideVCExists
{
    XCTAssertNotNil(self.editGuideVC, @"EditGuideViewController must exist");
}

-(void)testManagedObjectContextExists
{
    XCTAssertNotNil(self.editGuideVC.managedObjectContext, @"must have managed object context");
}

-(void)testGuideTitleDoesNotExist
{
    XCTAssertNil(self.editGuideVC.guideToEdit.title, @"title must be nil");
}

-(void)testGuideDoesNotExistIfTitleNotEnteredYet
{
    XCTAssertNil(self.editGuideVC.guideToEdit, @"no guide object should exist until a title has been entered");
}

-(void)testGuideObjectExistsIfTitleEntered
{
    [self.editGuideVC titleCompleted: @"some title"];
    XCTAssertNotNil(self.editGuideVC.guideToEdit, @"guide object must be created if a title has been entered");
}

-(void)testShowSaveAlertIsFalseIfThereIsNoGuideObject
{
    XCTAssertEqual(self.editGuideVC.showSaveAlert, NO,@"showSaveAlert should be NO");
}

-(void)testShowSaveAlertIsTrueIfThereIsAGuideObject
{
    [self.editGuideVC titleCompleted:@"some title"];
    XCTAssertEqual(self.editGuideVC.showSaveAlert, YES,@"showSaveAlert should be YES");
}

-(void)testGuideIsNotCreatedIfTitleIsEmptyString
{
    [self.editGuideVC titleCompleted:@""];
    XCTAssertNil(self.editGuideVC.guideToEdit, @"guide object should not be created for an empty title string");
}

-(void)testStepIsNotCreatedIfNoTextHasBeenEnteredIntoStepView
{
    [self.editGuideVC titleCompleted:@"some title"];
    [self.editGuideVC stepInstructionTextChanged:@""];
    XCTAssertEqual([self.editGuideVC.guideToEdit.stepInGuide count], 0,  @"there should be no steps in the guide");
}

-(void)testStepIsCreatedWhenTextEntered
{
    [self.editGuideVC titleCompleted:@"some title"];
    [self.editGuideVC stepInstructionTextChanged:@"some step instruction"];
    XCTAssertEqual([self.editGuideVC.guideToEdit.stepInGuide count], 1, @"there should be 1 step in the guide");
}

-(void)testNoChangesRecordedIfTitleNotEntered
{
    [self.editGuideVC titleCompleted: @""];
    XCTAssertEqual([self.moc hasChanges], NO, @"there should be no changes to the managed object");
}

-(void)testChangesRecordedIfTitleEntered
{
    [self.editGuideVC titleCompleted: @"some title"];
    XCTAssertEqual([self.moc hasChanges], YES, @"there should be changes to the managed object");
}

-(void)testNoChangesRecordedIfTitleOrStepNotChanged
{
    [self.editGuideVC titleCompleted: @"some title"];
    [self.editGuideVC stepInstructionTextChanged:@"some step instruction"];
    NSError *error;
    [self.moc save:&error];
    XCTAssertEqual([self.moc hasChanges], NO, @"there should be no changes to the managed object");
    
}

-(void)testChangesRecordedIfTitleChanged
{
    [self.editGuideVC titleCompleted: @"some title"];
    [self.editGuideVC stepInstructionTextChanged:@"some step instruction"];
    NSError *error;
    [self.moc save:&error];
    XCTAssertEqual([self.moc hasChanges], NO, @"there should be no changes to the managed object");
    
    [self.editGuideVC titleCompleted:@"another title"];
    XCTAssertEqual([self.moc hasChanges], YES, "there should be changes since the title changed");
    
}

-(void)testChangesRecordedIfStepChanged
{
    [self.editGuideVC titleCompleted: @"some title"];
    [self.editGuideVC stepInstructionTextChanged:@"some step instruction"];
    NSError *error;
    [self.moc save:&error];
    XCTAssertEqual([self.moc hasChanges], NO, @"there should be no changes to the managed object");
    
    [self.editGuideVC stepInstructionEntryCompleted:@"modified step instruction"];
    XCTAssertEqual([self.moc hasChanges], YES, "there should be changes since the step changed");
    
}
@end
