//
//  DataEntryDelegate.h
//  Talk Lists
//
//  Created by Susan Elias on 7/18/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataEntryDelegate <NSObject>

@required

-(void)entryTextChanged: (NSString *)textEntry autoAdvance: (BOOL)advance;
-(void)entryImageChanged: (UIImage *)imageEntry;
-(void)advanceView;

@end
