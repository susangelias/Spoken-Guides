//
//  Photo.h
//  Talk Lists
//
//  Created by Susan Elias on 5/8/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Guide, Step;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * assetLibraryURL;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSData * photoDelegate;
@property (nonatomic, retain) Guide *belongsToGuide;
@property (nonatomic, retain) Step *belongsToStep;

@end
