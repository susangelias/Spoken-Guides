//
//  Guide.h
//  Talk Lists
//
//  Created by Susan Elias on 4/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuideMetaData : NSObject

//  creater ID, guide ID
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSURL *fileURL;
@property (nonatomic) NSUInteger *guideID;
@property (strong, nonatomic) NSString *guideCategory;

@end
