//
//  Photo+Addendums.h
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Photo.h"

typedef void (^ASCompletionBlock)(BOOL success, NSDictionary *response, NSError *error);
@interface Photo (Addendums)

+(NSString *)entityName;
+(instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc;

-(void)retrieveImageWithCompletionBlock:(ASCompletionBlock)callback;
-(void)retreiveThumbNailWithCompletionBlock:(ASCompletionBlock)callback;

@end
