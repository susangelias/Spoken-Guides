//
//  Step+Addendums.m
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Step+Addendums.h"

@implementation Step (Addendums)

+(NSString *)entityName
{
    return @"Step";
}

+(instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:moc];
}


@end
