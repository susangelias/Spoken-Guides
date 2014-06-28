//
//  PFPhoto.m
//  Talk Lists
//
//  Created by Susan Elias on 6/24/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PFPhoto.h"

@implementation PFPhoto

@dynamic imageData;
@dynamic thumbnailData;
@dynamic belongsToObject;

+ (NSString *)parseClassName {
    return @"PFPhoto";
}
@end
