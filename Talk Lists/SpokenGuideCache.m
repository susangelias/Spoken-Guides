//
//  SpokenGuideCache.m
//  Talk Lists
//
//  Created by Susan Elias on 7/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "SpokenGuideCache.h"

@interface SpokenGuideCache()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation SpokenGuideCache

@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - Spoken Guide Cache

- (void)clear {
    [self.cache removeAllObjects];
}

#pragma mark - PFGuide objects

- (void)setAttributesForPFGuide:(PFGuide *)guide changedImage:(UIImage *)changedImage changedThumbnail:(UIImage *)changedThumbnail
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                guide, kPFGuideClassKey,
                                changedImage, kPFGuideChangedImage,
                                changedThumbnail, kPFGuideChangedThumbnail,
                                nil];
    [self setObject:attributes forKey:guide.objectId];
}

- (UIImage *)changedImageForGuide:(PFGuide *)guide
{
    NSDictionary *attributes = [self objectForKey:guide.objectId];
    UIImage *changedImage = [attributes objectForKey:kPFGuideChangedImage];
    return changedImage;
}

- (UIImage *)changedThumbnailForGuide:(PFGuide *)guide
{
    NSDictionary *attributes = [self objectForKey:guide.objectId];
    UIImage *changedThumbnail = [attributes objectForKey:kPFGuideChangedThumbnail];
    return changedThumbnail;
}

- (NSString *)titleForGuide:(PFGuide *)guide
{
    NSDictionary *attributes = [self objectForKey:guide.objectId];
    PFGuide *changedGuide = [attributes objectForKey:kPFGuideClassKey];
    return changedGuide.title;
}

#pragma mark - PFStep objects

- (void)setAttributesForPFStep:(PFStep *)step changedImage:(UIImage *)changedImage changedThumbnail:(UIImage *)changedThumbnail
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                step, kPFStepClassKey,
                                changedImage, kPFStepChangedImage,
                                changedThumbnail, kPFStepChangedThumbnail,
                                nil];
    [self setObject:attributes forKey:step.objectId];
}

- (UIImage *)changedImageForStep:(PFStep *)step
{
    NSDictionary *attributes = [self objectForKey:step.objectId];
    UIImage *changedImage = [attributes objectForKey:kPFStepChangedImage];
    return changedImage;
    
}

- (UIImage *)changedThumbnailForStep:(PFStep *)step
{
    NSDictionary *attributes = [self objectForKey:step.objectId];
    UIImage *changedThumbnail = [attributes objectForKey:kPFStepChangedThumbnail];
    return changedThumbnail;
    
}

- (NSString *)instructionForStep:(PFStep *)step
{
    NSDictionary *attributes = [self objectForKey:step.objectId];
    PFStep *changedStep = [attributes objectForKey:kPFStepClassKey];
    return changedStep.instruction;
}

@end
