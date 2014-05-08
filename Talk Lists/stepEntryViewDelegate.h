//
//  stepEntryViewDelegate.h
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol stepEntryViewDelegate <NSObject>

@required

-(void) stepInstructionEntered: (NSString *)instructionText;

@end
