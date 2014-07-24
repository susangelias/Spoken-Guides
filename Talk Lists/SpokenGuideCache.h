//
//  SpokenGuideCache.h
//  Talk Lists
//
//  Created by Susan Elias on 7/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFGuide.h"
#import "PFStep.h"

@interface SpokenGuideCache : NSCache

+ (id)sharedCache;

- (void)clear;

// PFGuide objects
- (void)setAttributesForPFGuide:(PFGuide *)guide changedImage:(UIImage *)changedImage changedThumbnail:(UIImage *)changedThumbnail;
- (UIImage *)changedImageForGuide:(PFGuide *)guide;
- (UIImage *)changedThumbnailForGuide:(PFGuide *)guide;
- (NSString *)titleForGuide:(PFGuide *)guide;

// PFStep objects
- (void)setAttributesForPFStep:(PFStep *)step changedImage:(UIImage *)changedImage changedThumbnail:(UIImage *)changedThumbnail;
- (UIImage *)changedImageForStep:(PFStep *)step;
- (UIImage *)changedThumbnailForStep:(PFStep *)step;
- (NSString *)instructionForStep:(PFStep *)step;

@end
