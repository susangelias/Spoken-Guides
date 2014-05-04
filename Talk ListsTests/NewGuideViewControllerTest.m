//
//  NewGuideViewControllerTest.m
//  Talk Lists
//
//  Created by Susan Elias on 5/2/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NewGuideViewController.h"

@interface NewGuideViewControllerTest : XCTestCase

@property (nonatomic, strong) NewGuideViewController *guideVC;

@end

@implementation NewGuideViewControllerTest

- (void)setUp
{
    [super setUp];
    self.guideVC = [[NewGuideViewController alloc]init];

}

- (void)tearDown
{
    self.guideVC = nil;
    [super tearDown];
}

-(void)testNewGuideViewControllerExists
{
    XCTAssertNotNil(self.guideVC, @"newGuideViewController object must exist");
}


@end
