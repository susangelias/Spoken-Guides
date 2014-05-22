//
//  addPhotoController.h
//  Talk Lists
//
//  Created by Susan Elias on 4/25/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface addPhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate >

@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSURL *assetLibraryURL;
@property (strong, nonatomic) NSString *albumName;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) ALAssetsLibrary *library;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;


@end
