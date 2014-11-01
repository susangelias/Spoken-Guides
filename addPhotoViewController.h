//
//  addPhotoController.h
//  Talk Lists
//
//  Created by Susan Elias on 4/25/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface addPhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate >

@property (strong, nonatomic) UIImage *selectedPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (nonatomic, strong) UIImagePickerController *picker;

@end
