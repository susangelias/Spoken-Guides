//
//  PFPhoto.h
//  Talk Lists
//
//  Created by Susan Elias on 6/24/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFPhoto : PFObject

+ (NSString *)parseClassName;

//@property (nonatomic, retain) NSString * assetLibraryURL;
@property (nonatomic, retain) PFFile * imageData;
@property (nonatomic, retain) PFFile * thumbnailData;
@property (nonatomic, retain) NSString *belongsToObject;

@end
