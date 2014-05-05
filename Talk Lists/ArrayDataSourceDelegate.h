//
//  previewViewControllerDelegate.h
//  Talk Lists
//
//  Created by Susan Elias on 5/1/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ArrayDataSourceDelegate <NSObject>

@optional

-(void)deletedRowAtIndex:(NSUInteger)index;
-(void)movedRowFrom:(NSUInteger)fromIndex To:(NSUInteger) toIndex;

@end
