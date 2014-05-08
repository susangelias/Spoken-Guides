//
//  Guide+Addendums.m
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Guide+Addendums.h"

@implementation Guide (Addendums)

+(NSString *)entityName
{
    return @"Guide";
}

+(instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:moc];
}


-(NSArray *)sortedSteps
{
    NSSortDescriptor *rankSort = [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES];
    NSArray *sorted;
    if (rankSort) {
        sorted = [self.stepInGuide sortedArrayUsingDescriptors:@[rankSort]];
    }
    return sorted;
}

@end
