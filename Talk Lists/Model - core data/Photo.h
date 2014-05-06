//
//  Photo.h
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * fileURL;
@property (nonatomic, retain) NSManagedObject *belongsToGuide;
@property (nonatomic, retain) NSManagedObject *belongsToStep;

@end
