//
//  PFStep.h
//  Talk Lists
//
//  Created by Susan Elias on 6/20/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Parse/Parse.h>
//#import "PFGuide.h"

@interface PFStep : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, retain) NSString * instruction;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSString *belongsToGuide;
//@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) NSData *photo;

@end
