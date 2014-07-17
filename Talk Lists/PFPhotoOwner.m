//
//  PFPhotoOwner.m
//  Talk Lists
//
//  Created by Susan Elias on 7/9/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PFPhotoOwner.h"
#import "PFPhoto.h"

@implementation PFPhotoOwner

@dynamic photo;


-(void) getImageInBackgroundWithBlock:(updateViewBlock)completionBlock {
    [self.photo fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFPhoto *photoObject = (PFPhoto *)object;
            PFFile *imageFile = [photoObject objectForKey:@"image"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    completionBlock([UIImage imageWithData:imageData]);
                }
            }];
        }
    }];
}

-(void) getThumbnailInBackgroundWithBlock:(updateViewBlock)completionBlock
{
    [self.photo fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFPhoto *photoObject = (PFPhoto *)object;
            PFFile *thumbnailFile = [photoObject objectForKey:@"thumbnail"];
            [thumbnailFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    completionBlock([UIImage imageWithData:imageData]);
                }
            }];
        }
    }];
}


@end
