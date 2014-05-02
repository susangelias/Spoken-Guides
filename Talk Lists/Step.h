//
//  Step.h
//  Talk Lists
//
//  Created by Susan Elias on 5/1/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Step : NSObject

@property (strong, nonatomic) NSString *instruction;
@property (strong, nonatomic) UIImage *photo;
@property (nonatomic) NSUInteger rank;          // position within the guide

@end
