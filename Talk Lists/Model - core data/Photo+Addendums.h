//
//  Photo+Addendums.h
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Photo.h"

@interface Photo (Addendums)

+(NSString *)entityName;
+(instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc;

@end
