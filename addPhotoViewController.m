//
//  addPhotoController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/25/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "addPhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Resize.h"

NSString *const kCancel = @"Cancel";
NSString *const kTakePhoto = @"Take Photo";
NSString *const kChoosePhoto = @"Choose Existing Photo";
NSString *const kRemovePhoto = @"Remove Photo From Guide";

@implementation addPhotoViewController 
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.doneButton.hidden = YES;
    self.redoButton.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    if (!self.photoView.image) {
        [self choosePhotoSource];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // extract new image
    UIImage *rawPhoto = [info[UIImagePickerControllerEditedImage] resizeToSquareImage];
    // resize to a square image for this app
    self.selectedPhoto = [rawPhoto resizeToSquareImage];
    
    // dismiss view controller
    [self dismissViewControllerAnimated:YES completion:NULL];   // have memory leak here - change UIImagePickerController to singleton

     // Display image
    if (self.selectedPhoto ) {
        // wait for imageView to render before attempting to display photo
        __weak typeof (self) weakSelf = self;
        [UIView animateWithDuration:0.0
                         animations:^{
                             [weakSelf.view addSubview:weakSelf.photoView];
                             weakSelf.doneButton.hidden = NO;
                             weakSelf.redoButton.hidden = NO;
                          }
                         completion:^(BOOL finished) {
                             weakSelf.photoView.image = weakSelf.selectedPhoto;
                         }
         ];
    }
    
  // NSLog(@"IMAGE %f x %f ", self.selectedPhoto.size.width, self.selectedPhoto.size.height);
   // NSLog(@"Thumbnail %f x %f ", self.selectedThumbnail.size.width, self.selectedThumbnail.size.height);

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.selectedPhoto = nil;
    // just dismiss the imagePickerController
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Choose photo source

- (IBAction)choosePhotoSource
{
 
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Photo Option"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        for (NSString *source in [self photoSources]) {
            [actionSheet addButtonWithTitle:source];
        }
    
    
        // if there is already a photo for this step list option to remove it
        if (self.selectedPhoto) {
            [actionSheet addButtonWithTitle:kRemovePhoto];
        }
        [actionSheet addButtonWithTitle:kCancel]; // put at bottom (don't do at all on iPad)
        
        [actionSheet showInView:self.view]; // different on iPad
}

- (NSDictionary *)photoSources
{
    NSMutableDictionary *sources = [[NSMutableDictionary alloc]init];
    // check if camera is avaiable
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ])
    {
        [sources setObject: [NSNumber numberWithInt:UIImagePickerControllerSourceTypeCamera] forKey:kTakePhoto];
    }
    // check if photo library is available
    if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypePhotoLibrary)]) {
        [sources setObject: [NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary] forKey:kChoosePhoto];
    }
    
    return [sources copy];
}



#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ( [choice isEqualToString:kTakePhoto] || [choice isEqualToString:kChoosePhoto] ) {
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
    else if ([choice isEqualToString:kCancel] ) {
        [self.cancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else if ([choice isEqualToString:kRemovePhoto]) {
        self.selectedPhoto = nil;
        [self performSegueWithIdentifier:@"photoAdded" sender:self];
    }
}



- (IBAction)redoPhoto:(UIButton *)sender {
    self.photoView.image = nil;
    self.doneButton.hidden = YES;
    self.redoButton.hidden = YES;
    [self choosePhotoSource];
}

@end
