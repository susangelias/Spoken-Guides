//
//  GuideContents.h
//  Talk Lists
//
//  Created by Susan Elias on 4/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepClassic.h"

@interface GuideContents : NSObject

@property (strong, nonatomic) NSMutableArray *steps;
@property (nonatomic) NSUInteger *guideID;
@property (strong, nonatomic) UIImage *guidePhoto;
@property (strong, nonatomic) NSURL *guidePhotoURL;

-(void)deleteStep:(NSUInteger)stepNumber;
-(void)moveStepFromNumber: (NSUInteger)fromNumber toNumber: (NSUInteger) newNumber;
-(void)insertStep:(NSUInteger)stepNumber withInstruction: (NSString *)text withPhoto: (UIImage *)photo;
-(void)replaceStepInstruction:(NSString *)stepText atNumber: (NSUInteger)stepNumber;
-(void)replaceStepPhoto:(UIImage *)stepPhoto atNumber: (NSUInteger)stepNumber;

@end
