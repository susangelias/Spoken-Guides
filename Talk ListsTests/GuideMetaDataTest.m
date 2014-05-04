//
//  GuideMetaDataTest.m
//  Talk Lists
//
//  Created by Susan Elias on 5/2/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GuideMetaData.h"

@interface GuideMetaDataTest : XCTestCase

@property (nonatomic, strong) GuideMetaData *metaData;

@end

@implementation GuideMetaDataTest

- (void)setUp
{
    [super setUp];
    self.metaData = [[GuideMetaData alloc] init];
}

- (void)tearDown
{
    self.metaData = nil;
    [super tearDown];
}

-(void)testGuideMetaDataObjectExists
{
    XCTAssertNotNil(self.metaData, @"guideMetaData object must exist");
}

-(void)testSettingGuideTitle
{
    NSString *someTitle = @"My New Guide";
    XCTAssertNil(self.metaData.title, @"guide title should be nil before setting");
    
    self.metaData.title = someTitle;
    XCTAssertEqual(self.metaData.title, someTitle, @"guide title should be set");
}


@end
