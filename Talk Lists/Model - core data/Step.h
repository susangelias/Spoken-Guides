//
//  Step.h
//  Talk Lists
//
//  Created by Susan Elias on 5/8/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Guide, Photo;

@interface Step : NSManagedObject

@property (nonatomic, retain) NSString * instruction;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) Guide *belongsToGuide;
@property (nonatomic, retain) Photo *photo;

@end
