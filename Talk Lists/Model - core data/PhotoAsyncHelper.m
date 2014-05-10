//
//  PhotoAsyncHelper.m
//  Talk Lists
//
//  Created by Susan Elias on 5/8/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PhotoAsyncHelper.h"

@implementation PhotoAsyncHelper

-(PhotoAsyncHelper *)initWithPhotoObject:(Photo *)photoObject
{

    self = [super init];
    self.photoObject = photoObject;
    return self;
}


-(void)thumbnailWithAssetLibraryURL
{
    __block UIImage *thumbnail = [UIImage imageWithData:self.photoObject.thumbnail];
    
    if (self.photoObject.assetLibraryURL && !self.photoObject.thumbnail) {
        // retrieve the thumbnail from the photo asset library and save it to the photo model object
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSURL *assetURL = [[NSURL alloc] initWithString:self.photoObject.assetLibraryURL];
        [library assetForURL:assetURL
                 resultBlock:^(ALAsset *asset) {
                     thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
                     self.photoObject.thumbnail = UIImagePNGRepresentation(thumbnail);      // add thumbnail to our core data model
                     [self.photoAsyncHelperDelegate thumbNailRetrieved:thumbnail];
                 } failureBlock:^(NSError *error) {
                     if (error) {
                         NSLog(@"Failed to retrieve thumbnail from asset library: %@", error);
                     }
                 }];
    }
    else {
        // already have the thumbnail in the model so return it
        [self.photoAsyncHelperDelegate thumbNailRetrieved:thumbnail];
    }
}


@end
