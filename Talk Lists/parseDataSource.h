//
//  parseDataSource.h
//  Talk Lists
//
//  Created by Susan Elias on 6/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "parseDataSourceDelegate.h"

typedef void(^configureCellBlock)(UITableViewCell *, id);

@interface parseDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *queryResults;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (nonatomic, copy) configureCellBlock configureCell;
@property (nonatomic) BOOL editingAllowed;
@property (nonatomic) BOOL rearrangingAllowed;
@property (nonatomic, weak) id <parseDataSourceDelegate> parseDataSourceDelegate;
@property (nonatomic, strong) PFQuery *query;

-(parseDataSource *)initWithPFObjectClassName:(NSString *)PFObjectClassName
                                  withSortKey: (NSString *)sortKey
                                 withMatchKey: (NSString *)matchKey
                                 withPFObject: (id)parentObject
                          withCellIndentifier: (NSString *)cellID
                           configureCellBlock:configCellBlock;

-(void)refreshQuery;

@end
