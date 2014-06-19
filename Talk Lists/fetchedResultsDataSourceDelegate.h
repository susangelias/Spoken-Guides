//
//  fetchedResultsDataSourceDelegate.h
//  Talk Lists
//
//  Created by Susan Elias on 6/14/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol fetchedResultsDataSourceDelegate <NSObject>

@optional

-(void)deletedRowAtIndex:(NSUInteger)index;
-(void)movedRowFrom:(NSUInteger)fromIndex To:(NSUInteger) toIndex;

@end
