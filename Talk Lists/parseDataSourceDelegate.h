//
//  parseDataSourceDelegate.h
//  Talk Lists
//
//  Created by Susan Elias on 6/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol parseDataSourceDelegate <NSObject>

@optional

-(void)deletedRowAtIndex:(NSUInteger)index;
-(void)movedRowFrom:(NSUInteger)fromIndex To:(NSUInteger) toIndex;
-(void)queryComplete;

@end
