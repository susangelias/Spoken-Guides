//
//  PFPhotoOwner.h
//  Talk Lists
//
//  Created by Susan Elias on 7/9/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Parse/Parse.h>


typedef void(^updateViewBlock)(UIImage *retrieveImage);

// Abstract class which is a Parse Object that contains a PFPhoto object.
// There are no methods that should be overridden.
// An object of this class should never be instantiated and saved to the Parse backend.

@interface PFPhotoOwner : PFObject 

@property (nonatomic, retain) id photo;                // object stored here will be a PFPhoto

-(void) getImageInBackgroundWithBlock:(updateViewBlock)completionBlock;
-(void) getThumbnailInBackgroundWithBlock:(updateViewBlock)completionBlock;

@end
