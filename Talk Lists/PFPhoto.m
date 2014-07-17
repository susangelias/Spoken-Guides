//
//  PFPhoto.m
//  Talk Lists
//
//  Created by Susan Elias on 6/24/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PFPhoto.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFPhoto

@dynamic image;
@dynamic thumbnail;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

@end
