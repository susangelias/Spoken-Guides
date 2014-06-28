//
//  PFGuide.h
//  Talk Lists
//
//  Created by Susan Elias on 6/16/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Parse/Parse.h>
//#import "Guide.h"
#import "PFStep.h"

@interface PFGuide : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, retain) NSString * classification;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain, readonly) PFRelation *pfSteps;
//@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) NSData *photo;

@property (nonatomic, strong) NSMutableArray *rankedStepsInGuide;

-(void)deleteStepAtIndex:(NSUInteger)index;
-(void)moveStepFromNumber:(NSUInteger)fromIndex toNumber:(NSUInteger)toIndex;
-(PFStep *)stepForRank:(NSUInteger)rank;



@end
