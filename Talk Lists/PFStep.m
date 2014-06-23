//
//  PFStep.m
//  Talk Lists
//
//  Created by Susan Elias on 6/20/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PFStep.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFStep

@dynamic instruction;
@dynamic rank;
@dynamic belongsToGuide;
@dynamic photo;

+ (NSString *)parseClassName {
    return @"PFStep";
}

@end
