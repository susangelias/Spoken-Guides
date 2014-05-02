//
//  ArrayDataSourceTest.m
//  Talk Lists
//
//  Created by Susan Elias on 5/2/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ArrayDataSource.h"
#import "OCMock.h"


typedef void(^TableViewCellConfigureBlock)(UITableViewCell *, id);

@interface ArrayDataSourceTest : XCTestCase

@end

@implementation ArrayDataSourceTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testInitializing
{
    XCTAssertNil([[ArrayDataSource alloc]init], @"Should not be allowed");
    TableViewCellConfigureBlock block = ^(UITableViewCell *a, id b){};
    id obj1 = [[ArrayDataSource alloc] initWithItems:@[]
                                        cellIDString:@"foo"
                                  configureCellBlock:block];
    XCTAssertNotNil(obj1, @"");
}

-(void)testOneSectionInTheTableView
{
    ArrayDataSource *dataSource = [[ArrayDataSource alloc] initWithItems:@[@"item a", @"item b"]
                                                            cellIDString:@"foo cell"
                                                      configureCellBlock:nil];

    XCTAssertThrows([dataSource tableView:nil
                    numberOfRowsInSection:2], @"Table View data source is only configured to handle 1 section");
    
}
-(void)testCellConfiguration
{
    __block UITableViewCell *configuredCell = nil;
    __block id configuredObject = nil;
    TableViewCellConfigureBlock block = ^(UITableViewCell *a, id b) {
        configuredCell = a;
        configuredObject = b;
    };
    ArrayDataSource *dataSource = [[ArrayDataSource alloc] initWithItems:@[@"item a", @"item b"]
                                                            cellIDString:@"foo cell"
                                                      configureCellBlock:block];
    id mockTableView = [OCMockObject mockForClass:[UITableView class]];
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [[[mockTableView expect] andReturn:cell]
        dequeueReusableCellWithIdentifier:@"foo cell"
                             forIndexPath:indexPath];
    
    id result = [dataSource tableView:mockTableView cellForRowAtIndexPath:indexPath];
    
    XCTAssertEqual(result, cell, @"Should return the dummy cell.");
    XCTAssertEqual(configuredCell, cell, @"This should have been passed to the block");
    XCTAssertEqualObjects(configuredObject, @"item a", @"This should have been passed to the block.");
    [mockTableView verify];
     }
@end
