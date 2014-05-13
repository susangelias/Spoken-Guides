//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SaveImageCompletion)(NSURL *assetLibraryURL,  NSError* error);
typedef void(^GetImageCompletion)(UIImage *image, NSError *error);

@interface ALAssetsLibrary(CustomPhotoAlbum)

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void)getThumbNailForAssetURL:(NSURL*)assetURL  withCompletionBlock:(GetImageCompletion)completionBlock;
-(void)getImageForAssetURL:(NSURL*)assetURL  withCompletionBlock:(GetImageCompletion)completionBlock;

@end