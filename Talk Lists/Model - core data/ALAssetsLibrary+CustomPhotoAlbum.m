//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation ALAssetsLibrary(CustomPhotoAlbum)

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    //write the image data to the assets library (camera roll)
    [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation
                       completionBlock:^(NSURL* assetURL, NSError* error) {
                           
                           //error handling
                           if (error!=nil) {
                               completionBlock(assetURL, error);
                               return;
                           }
                           
                           //add the asset to the custom photo album
                           [self addAssetURL: assetURL
                                     toAlbum:albumName
                         withCompletionBlock:completionBlock];
                           
                       }];
}

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    __block BOOL albumWasFound = NO;
    __block ALAssetsLibraryAccessFailureBlock failBlock;
    //search all photo albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            
                            //compare the names of the albums
                            if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                
                                //target album is found
                                albumWasFound = YES;
                                
                                //get a hold of the photo's asset instance
                                [self assetForURL: assetURL
                                      resultBlock:^(ALAsset *asset) {
                                          
                                          //add photo to the target album
                                          [group addAsset: asset];
                                          
                                          //run the completion block
                                          completionBlock(assetURL, nil);
                                          
                                      } failureBlock: failBlock];
                                
                                //album was found, bail out of the method
                                return;
                            }
                            
                            if (group==nil && albumWasFound==NO) {
                                //photo albums are over, target album does not exist, thus create it
                                //create new assets album
                                [self addAssetsGroupAlbumWithName:albumName
                                                      resultBlock:^(ALAssetsGroup *group) {
                                                          
                                                          //get the photo's instance
                                                          [self assetForURL: assetURL
                                                                    resultBlock:^(ALAsset *asset) {
                                                                        
                                                                        //add photo to the newly created album
                                                                        [group addAsset: asset];
                                                                        
                                                                        //call the completion block
                                                                        completionBlock(assetURL,nil);
                                                                        
                                                                    } failureBlock: failBlock];
                                                          
                                                      } failureBlock: failBlock];
                                
                                //should be the last iteration anyway, but just in case
                                return;
                            }
                            
                        } failureBlock: failBlock];
    
}

//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Susan G Elias 5/1/2014
//  Copyright (c) 2014 GriffTech. All rights reserved.
//


-(void)getThumbNailForAssetURL:(NSURL*)assetURL  withCompletionBlock:(GetImageCompletion)completionBlock
{
    //get a hold of the photo's asset instance
    __block UIImage *tNail;
    [self assetForURL: assetURL
          resultBlock:^(ALAsset *asset) {
              tNail = [UIImage imageWithCGImage:[asset thumbnail]];
              //run the completion block
              completionBlock(tNail, nil);
          } failureBlock:^(NSError *error) {
              if (error) {
                  NSLog(@"Failed to retrieve thumbnail from asset library: %@", error);
              }
          }];
}

-(void)getImageForAssetURL:(NSURL*)assetURL  withCompletionBlock:(GetImageCompletion)completionBlock
{
    //get a hold of the photo's asset instance
    __block UIImage *image;
    [self assetForURL: assetURL
          resultBlock:^(ALAsset *asset) {
              ALAssetRepresentation *imageRep = [asset defaultRepresentation];
              image = [UIImage imageWithCGImage:[imageRep fullScreenImage]];
              //run the completion block
              completionBlock(image, nil);
          } failureBlock:^(NSError *error) {
              if (error) {
                  NSLog(@"Failed to retrieve image from asset library: %@", error);
              }
          }];
}

@end
