//
//  GuideContents.h
//  Talk Lists
//
//  Created by Susan Elias on 4/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Step.h"

@interface GuideContents : NSObject

@property (strong, nonatomic) NSMutableArray *steps;
@property (nonatomic) NSUInteger *guideID;
@property (strong, nonatomic) UIImage *guidePhoto;

-(NSUInteger)numberOfSteps;
-(void)deleteStep:(NSUInteger)stepNumber;
-(void)moveStepFromNumber: (NSUInteger)fromNumber toNumber: (NSUInteger) newNumber;
-(void)insertStep:(NSUInteger)stepNumber;

@end
