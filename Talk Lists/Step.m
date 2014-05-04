//
//  Step.m
//  Talk Lists
//
//  Created by Susan Elias on 5/1/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Step.h"

@implementation Step

-(NSString *)instruction
{
    if (!_instruction) {
        _instruction = [NSString stringWithFormat:@"instruction %ul", rand()];
    }
    return _instruction;
}

-(UIImage *)photo {
    if (!_photo) {
        _photo = [[UIImage alloc] init];
    }
    return _photo;
}

@end
