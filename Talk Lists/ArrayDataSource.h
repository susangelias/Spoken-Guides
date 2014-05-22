//
//  ArrayDataSource.h
//  Talk Lists
//
//  Created by Susan Elias on 4/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArrayDataSourceDelegate.h"

typedef void(^configureCellBlock)(UITableViewCell *, id);

@interface ArrayDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (nonatomic, copy) configureCellBlock configureCell;
@property (nonatomic) BOOL editingAllowed;
@property (nonatomic) BOOL rearrangingAllowed;
@property (nonatomic, weak) id <ArrayDataSourceDelegate> arrayDataSourceDelegate;

-(ArrayDataSource *)initWithItems:(NSArray *)initialItems
                     cellIDString:(NSString *)IDString
               configureCellBlock:configCellBlock;

@end
