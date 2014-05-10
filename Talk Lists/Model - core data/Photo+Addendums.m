//
//  Photo+Addendums.m
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Photo+Addendums.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation Photo (Addendums)

+(NSString *)entityName
{
    return @"Photo";
}

+(instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:moc];
}


@end
