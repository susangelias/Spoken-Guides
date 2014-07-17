//
//  addPhotoController.h
//  Talk Lists
//
//  Created by Susan Elias on 4/25/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <AssetsLibrary/AssetsLibrary.h>
//#import "ALAssetsLibrary+CustomPhotoAlbum.h"


@interface addPhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate >

//@property (strong, nonatomic) NSURL *assetLibraryURL;
@property (strong, nonatomic) UIImage *selectedPhoto;
@property (strong, nonatomic) UIImage *selectedThumbnail;
//@property (weak, nonatomic) NSString *albumName;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
//@property (strong, nonatomic) ALAssetsLibrary *library;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) id parseObject;


@end
