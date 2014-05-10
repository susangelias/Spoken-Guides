//
//  PhotoAsyncHelper.h
//  Talk Lists
//
//  Created by Susan Elias on 5/8/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "photoAsyncHelperDelegate.h"
#import "Photo.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoAsyncHelper : NSObject

@property (strong, nonatomic) id <photoAsyncHelperDelegate> photoAsyncHelperDelegate;
@property (weak, nonatomic) Photo *photoObject;

- (PhotoAsyncHelper *)initWithPhotoObject:(Photo *)photoObject;

-(void)thumbnailWithAssetLibraryURL;

@end
