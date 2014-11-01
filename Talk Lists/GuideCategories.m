//
//  categories.m
//  Talk Lists
//
//  Created by Susan Elias on 4/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideCategories.h"

NSString *const kALLCATAGORIES = @"ALL CATAGORIES";

@implementation GuideCategories

- (NSArray *)categoryKeys
{
    if (!_categoryKeys)
    {
        _categoryKeys = @[NSLocalizedString(@"GENERAL", nil),
                            NSLocalizedString(@"COOKING", nil),
                            NSLocalizedString(@"DIY", nil),
                            NSLocalizedString(@"AUTOMOTIVE", nil),
                            NSLocalizedString(@"HOME & GARDEN", nil),
                            NSLocalizedString(@"HEALTH & FITNESS", nil)];
    }
    return _categoryKeys;
}


- (NSArray *)categoryStrings
{
    if (!_categoryStrings)
    {
        NSMutableArray *temp = [[NSMutableArray alloc]init];
        [self.categoryKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [temp addObject:[NSString stringWithFormat:@"%lu",(unsigned long) idx]];
        }];
        _categoryStrings = [temp copy];
    }
    return _categoryStrings;
}


- (NSDictionary *)categories
{
    if (!_categories) {
        _categories = [[NSDictionary alloc] initWithObjects:self.categoryStrings forKeys:self.categoryKeys];
    }
    return _categories;
}


@end
