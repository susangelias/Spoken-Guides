//
//  Guide+Addendums.h
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Guide.h"

@interface Guide (Addendums)

+(NSString *)entityName;
+(instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc;

-(NSArray *)sortedSteps;
-(void)deleteStepAtIndex:(NSUInteger)index;

@end
