//
//  PFPhoto.h
//  Talk Lists
//
//  Created by Susan Elias on 6/24/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFPhoto : PFObject  <PFSubclassing>

+ (NSString *)parseClassName;

//@property (nonatomic, retain) NSString * assetLibraryURL;
@property (nonatomic, retain) PFFile * image;
@property (nonatomic, retain) PFFile * thumbnail;

@end
