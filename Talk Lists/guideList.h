//
//  guideList.h
//  Talk Lists
//
//  Created by Susan Elias on 4/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface guideList : NSObject

@property (nonatomic, strong) NSNumber *guideCategory;    // guide category to limit the search
@property (nonatomic, strong) NSArray *guides;           // list of guides of the given category - guide metadata
@property (nonatomic) BOOL local;                       // YES = local file system, NO = Firebase server

@end
