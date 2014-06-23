//
//  ShareControllerTest.m
//  Talk Lists
//
//  Created by Susan Elias on 6/16/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ShareController.h"
#import "Guide.h"

@interface ShareControllerTest : XCTestCase

@property (nonatomic, strong) ShareController *shareControl;
@property (nonatomic, strong) Guide *cdGuide;

@end

@implementation ShareControllerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.shareControl = [[ShareController alloc] init];
    self.cdGuide = [[Guide alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.shareControl = nil;
    [super tearDown];
}

- (void)testCreateObjectInBackendSucceeds
{
    self.cdGuide.title = @"myNewTestGuide";
    self.cdGuide.classification = @"GENERAL";
    
}

@end
