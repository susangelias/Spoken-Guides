//
//  categories.h
//  Talk Lists
//
//  Created by Susan Elias on 4/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kALLCATAGORIES;

@interface GuideCategories : NSObject

@property (strong, nonatomic) NSDictionary *categories;
@property (strong, nonatomic) NSArray *categoryStrings;
@property (strong, nonatomic) NSArray *categoryKeys;

@end
