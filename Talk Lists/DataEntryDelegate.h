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

-(void)entryTextChanged: (NSString *)textEntry;
-(void)entryImageChanged: (UIImage *)imageEntry;

@end
