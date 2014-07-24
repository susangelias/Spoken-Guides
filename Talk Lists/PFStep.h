//
//  PFStep.h
//  Talk Lists
//
//  Created by Susan Elias on 6/20/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Parse/Parse.h>

#pragma mark - Guide Constants for SpokenGuideCache
// Class key
extern NSString *const kPFStepClassKey;

// keys
extern NSString *const kPFStepChangedImage;
extern NSString *const kPFStepChangedThumbnail;

@interface PFStep : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, retain) NSString * instruction;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) PFFile * image;
@property (nonatomic, retain) PFFile * thumbnail;


@end
