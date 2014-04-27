//
//  addPhotoController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/25/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "addPhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation addPhotoViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.doneButton.hidden = YES;
    self.redoButton.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    if (!self.photo) {
        [self choosePhotoSource];
    }
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // extract new image
    UIImage *selectedPhoto = info[UIImagePickerControllerEditedImage];
    
    // save image to user's photo stream if they took a picture
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(selectedPhoto, nil, nil, nil);
    }
    
    // dismiss view controller
    [self dismissViewControllerAnimated:YES completion:NULL];

    // clean up photo for our app's use and display it
    if (selectedPhoto) {
        self.photo = [self cleanUpImage:selectedPhoto];
        
        // wait for imageView to render before attempting to display photo
        [UIView animateWithDuration:0.0
                         animations:^{
                             [self.view addSubview:self.photoView];
                             self.doneButton.hidden = NO;
                             self.redoButton.hidden = NO;
                         }
                         completion:^(BOOL finished) {
                             self.photoView.image = self.photo;
                         }
         ];
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // just dismiss the imagePickerController
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Choose photo source

- (IBAction)choosePhotoSource
{
 
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Photo Source"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        for (NSString *source in [self photoSources]) {
            [actionSheet addButtonWithTitle:source];
        }
        [actionSheet addButtonWithTitle:@"Cancel"]; // put at bottom (don't do at all on iPad)
        
        [actionSheet showInView:self.view]; // different on iPad
}

- (NSDictionary *)photoSources
{
    return @{ @"Take Photo" : [NSNumber numberWithInt:UIImagePickerControllerSourceTypeCamera],
              @"Choose Existing Photo" :[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]
              };
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ( ![choice isEqualToString:@"Cancel"]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = [[self photoSources][choice] integerValue];
        picker.delegate = self;
        picker.allowsEditing = YES;

        NSString *desired = (NSString *)kUTTypeImage;
        if ([[UIImagePickerController availableMediaTypesForSourceType:picker.sourceType] containsObject:desired]) {
            picker.mediaTypes = @[desired];
        }
        else {
            // fail, can't get media type desired
        }

        [self presentViewController:(UIViewController *)picker
                           animated:YES
                         completion:NULL];
    }
    else {
        [self.cancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }

}


- (IBAction)redoPhoto:(UIButton *)sender {
    self.photoView.image = nil;
    self.photo = nil;
    self.doneButton.hidden = YES;
    self.redoButton.hidden = YES;
    [self choosePhotoSource];
}

#pragma mark Helpers

-(UIImage *)cleanUpImage: (UIImage *)rawImage
{
    UIImage *cleanedImage;
    CGImageRef coreGraphicsImage = rawImage.CGImage;
    CGFloat height = CGImageGetHeight(coreGraphicsImage);
    CGFloat width = CGImageGetWidth(coreGraphicsImage);
    CGRect crop;
    // Want to use square images instead of rectangle, so crop to do this
    if (height > width) {
        crop.size.height = crop.size.width = width;
        crop.origin.x = 0;
        crop.origin.y = floorf((height- width)/2);
    }
    else {
        crop.size.height = crop.size.width = height;
        crop.origin.y = 0;
        crop.origin.x = floorf((width-height)/2);
    }
    CGImageRef croppedImage = CGImageCreateWithImageInRect(coreGraphicsImage, crop);
    
    // scale down image to smaller size and make sure it is oriented the way the picture was taken
    cleanedImage = [UIImage imageWithCGImage:croppedImage
                                       scale:MAX(crop.size.height/512, 1.0)
                                 orientation:rawImage.imageOrientation];
    
    // release core graphics images as ARC does not do this for us
    CGImageRelease(croppedImage);
    CGImageRelease(coreGraphicsImage);
    
    return cleanedImage;
}

@end
