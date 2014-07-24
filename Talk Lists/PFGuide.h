//
//  PFGuide.h
//  Talk Lists
//
//  Created by Susan Elias on 6/16/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Parse/Parse.h>
#import "PFStep.h"

typedef void(^updateViewBlock)(UIImage *retrieveImage);
typedef void(^deleteCompleteBlock) (void);

#pragma mark - Guide Constants for SpokenGuideCache
// Class key
extern NSString *const kPFGuideClassKey;

// keys
extern NSString *const kPFGuideChangedImage;
extern NSString *const kPFGuideChangedThumbnail;

@interface PFGuide : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, retain) NSString * classification;
//@property (nonatomic, retain) NSDate * creationDate;
//@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSString * title;
//@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain, readonly) PFRelation *pfSteps;
@property (nonatomic, retain) PFFile * image;
@property (nonatomic, retain) PFFile * thumbnail;

@property (nonatomic, strong) NSMutableArray *rankedStepsInGuide;

-(void)deleteStepAtIndex:(NSUInteger)index withCompletionBlock:(deleteCompleteBlock)completionBlock;
-(void)moveStepFromNumber:(NSUInteger)fromIndex toNumber:(NSUInteger)toIndex;
-(PFStep *)stepForRank:(NSUInteger)rank;



@end
