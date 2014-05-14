//
//  NewGuideTitleViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "NewGuideViewController.h"
#import "addPhotoViewController.h"
#import "previewViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "GuideCategories.h"
#import "titleViewDelegate.h"
#import "titleView.h"
#import "stepEntryViewDelegate.h"
#import "stepEntryView.h"
#import "Guide+Addendums.h"
#import "Step+Addendums.h"
#import "Photo+Addendums.h"

@interface NewGuideViewController () <UIActionSheetDelegate, UIAlertViewDelegate, titleViewDelegate, stepEntryViewDelegate >

// view properties
@property (weak, nonatomic) IBOutlet UITextField *guideTitle;
@property (strong, nonatomic) titleView *guideTitleView;

@property (weak, nonatomic) IBOutlet UITextView *StepTextView;
@property (strong, nonatomic) stepEntryView *stepInstruction;
@property (weak, nonatomic) IBOutlet UITextView *swapTextView;
@property (weak, nonatomic) IBOutlet UILabel *textViewPlaceholder;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

// model properties
@property (strong, nonatomic) Guide *guideInProgress;
@property (strong, nonatomic) Step *stepInProgess;
@property (strong, nonatomic) Photo *userPhoto;

@end

@implementation NewGuideViewController
{
    int stepNumber;

}


#pragma mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
  
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up guide title entry view
    self.guideTitleView = [[titleView alloc] initWithTextField:self.guideTitle];
    self.guideTitleView.guideTitleDelegate = self;

    
    // make sure step text views are hidden to start with
    self.StepTextView.hidden = YES;
    self.swapTextView.hidden = YES;
    self.textViewPlaceholder.hidden = YES;
    
    stepNumber = 0;
    
    // make sure a camera or photo library is available before enabling the Add Photo button
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        self.addPhotoButton.enabled = YES;
        self.addPhotoButton.hidden = NO;
    }
    else {
        self.addPhotoButton.hidden = YES;
    }
   
    [self.navigationItem.leftBarButtonItem setTarget:self];
    [self.navigationItem.leftBarButtonItem setAction:@selector(doneButtonPressed:)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
}

#pragma mark <titleViewDelegate>

-(void)titleEntered:(NSString*)title
{
    self.guideInProgress.title = title;
    self.navigationItem.title = title;
    
    // update user's onscreen instructions
    [self updateStepText];
    
    // Clear the photo image of the guide title - move to photoView class
    if (self.imageView.image) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionTransitionFlipFromRight
                         animations:^{
                             self.imageView.image = nil;
                         }
                         completion:^(BOOL finished) {
                             self.userPhoto = nil;// release pointer to current step's photo core data object which will force a new photo object to be created for the 1st step, if needed

                         }];
    }

    // create the step entry objects
    self.stepInstruction = [[stepEntryView alloc]initWithPrimaryTextView:self.StepTextView secondaryTextView: self.swapTextView];
    self.stepInstruction.stepEntryDelegate = self;
    self.stepInstruction.textViewPlaceholder = self.textViewPlaceholder;

}

#pragma mark <stepEntryViewDelegate>

-(void) stepInstructionEntered: (NSString *)instructionText
{
    // save instructions in model
    self.stepInProgess.instruction = instructionText;
    
    // update user's onscreen instructions
    [self updateStepText];
    
    // clear the photo image
    self.imageView.image = nil;
    self.userPhoto = nil;   // release pointer to current step's photo core data object which will force a new photo object to be created when the user take's or chooses another photo

}

#pragma mark Add Photo unwind segues

- (IBAction)photoAdded:(UIStoryboardSegue *)segue
{
    addPhotoViewController *addPhotoVC = (addPhotoViewController *)segue.sourceViewController;

    if (addPhotoVC.assetLibraryURL) {
        self.userPhoto.assetLibraryURL = [addPhotoVC.assetLibraryURL absoluteString];
   
        // Retreive the thumbnail of the photo so it can be displayed in the delegate method
        [addPhotoVC.library getThumbNailForAssetURL:[NSURL URLWithString:self.userPhoto.assetLibraryURL]
                                withCompletionBlock:^(UIImage *image, NSError *error) {
                                    // save thumbnail to model
                                    self.userPhoto.thumbnail = UIImagePNGRepresentation(image);
                                    // display thumbail on this screen
                                    self.imageView.image = image;
                                }];
    }
 
    // resume editing of step text
    [self resetFirstResponder];
 
}

- (IBAction)photoCanceled:(UIStoryboardSegue *)segue
{
    // resume editing of step text
    [self resetFirstResponder];
}




#pragma mark Preview unwind segue

- (IBAction)finishedPreview:(UIStoryboardSegue *)segue
{
    // finished looking at the preview
    [self resetFirstResponder];
}

#pragma mark Set Category Button

- (IBAction)setCategoryPressed
{
    [self.guideTitle resignFirstResponder];
    [self.StepTextView resignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Catagory for Your Guide"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSString *category in [self categoryChoices]) {
        [actionSheet addButtonWithTitle:category];
    }
    [actionSheet addButtonWithTitle:@"Cancel"]; // put at bottom (don't do at all on iPad)
    
    [actionSheet showInView:self.view]; // different on iPad
}

- (NSDictionary *)categoryChoices
{
    GuideCategories *guideCats = [[GuideCategories alloc]init];
    return [guideCats categories];
}

#pragma mark UIActionSheetDelegate for Category Action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ( ![choice isEqualToString:@"Cancel"]) {
        // save category to model
        self.guideInProgress.classification = choice;
        self.categoryLabel.text = choice;
     }
    else {
        // do nothing
        self.categoryLabel.text = @"";
    }
    
}

#pragma  mark Done Button Actions

- (IBAction)doneButtonPressed:(UIButton *)sender {
    
    [self.guideTitle resignFirstResponder];
    [self.StepTextView resignFirstResponder];
/*
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Save Changes ?"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"Discard Guide"
                                                    otherButtonTitles:@"Save Guide\n(You can choose to publish it later from the Browse screen.", nil];
  */
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finish Guide"
                                                    message:@"Do you want to save your guide ?\n(You can choose to publish it later from the Browse screen.)"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save",@"Discard Changes", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( (!buttonIndex == 0) && (self.guideInProgress) )
    {
        if (buttonIndex == 1) {
              // save guide to core data
            if (self.guideInProgress.title) {
                NSError *error;
                [self.managedObjectContext save:&error];
                if (error) {
                    NSLog(@"ERROR saving context: %@", error);
                }
            }
        }
        else if (buttonIndex == 2) {
            // discard changes
            [self.managedObjectContext deleteObject:self.guideInProgress];
        }
   
        
        // return to main screen
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"previewSegue"] )
    {
        if ([[segue destinationViewController] isKindOfClass:[previewViewController class]]) {
            previewViewController *destController = [segue destinationViewController];
            destController.guideToPreview = self.guideInProgress;
            if (self.StepTextView.hidden == NO) {
                // add in progress step to guide even of user has not hit the Next key yet
              //  self.stepInProgess.instruction = self.StepTextView.text;
            }
            else if (self.guideTitle.hidden == NO) {
                // show title in progress in preview
                destController.titleToPreview = self.guideTitle.text;
            }

        }
    }
    else if ([segue.identifier isEqualToString:@"addPhotoSegue"] ) {
        if ([[segue destinationViewController] isKindOfClass:[addPhotoViewController class]]) {
            addPhotoViewController *destController = [segue destinationViewController];
            destController.albumName = self.guideInProgress.uniqueID;
        }

    }
}


#pragma mark Helpers
-(void)updateStepText
{
    // moving on to the next step so let go of the current step
    self.stepInProgess = nil;
    
    // Change the user directions for the next step
    stepNumber++;
    self.textViewPlaceholder.text = [NSString stringWithFormat:@"Step %d\n\nEnter instructions here", stepNumber];
    
    // record the step number in the model
    self.stepInProgess.rank = [NSNumber numberWithInteger:stepNumber];
}

-(void)resetFirstResponder {
    if (self.StepTextView.hidden == NO) {
        //   self.StepTextView.clearsOnBeginEditing = NO;
        [UIView animateWithDuration:0.0     // move to stepView class
                         animations:^{
                             [self.view addSubview:self.StepTextView];
                         }
                         completion:^(BOOL finished) {
                             [self.StepTextView becomeFirstResponder];
                         }
         ];
    }
    else if (self.guideTitle.hidden == NO) {
        self.guideTitle.clearsOnBeginEditing = NO;  // move to titleView class
        [UIView animateWithDuration:0.0
                         animations:^{
                             [self.view addSubview:self.guideTitle];
                         }
                         completion:^(BOOL finished) {
                             [self.guideTitle becomeFirstResponder];
                         }
         ];
        
    }
    
}

#pragma mark Initializations


-(Guide *)guideInProgress
{
    if (!_guideInProgress) {
        _guideInProgress = [Guide insertNewObjectInManagedObjectContext:self.managedObjectContext];
        // set this guide's unique ID
#warning add user's ID to the uniqueID string
        _guideInProgress.uniqueID = [NSString stringWithFormat:@"Talk Notes %d", rand()];
        GuideCategories *cats = [[GuideCategories alloc] init];
        _guideInProgress.classification = cats.categoryStrings[0];  // Set to default category and let the user change this if they want
        _guideInProgress.creationDate = [NSDate dateWithTimeIntervalSinceNow:0];
    }
    return _guideInProgress;
}

-(Step *)stepInProgess
{
    if (!_stepInProgess) {
        _stepInProgess = [Step insertNewObjectInManagedObjectContext:self.managedObjectContext];
        [self.guideInProgress addStepInGuideObject:_stepInProgess];
    }
    return _stepInProgess;
}

-(Photo *)userPhoto
{
    if (!_userPhoto) {
        _userPhoto = [Photo insertNewObjectInManagedObjectContext:self.managedObjectContext];
         // if the guideTitle view is not hidden then this photo belongs to the guide
        if (self.guideTitle.hidden == NO) {
            self.guideInProgress.photo = _userPhoto;
        }
        else
            // else photo belongs to the current step
        {
            self.stepInProgess.photo = _userPhoto;
        }

     }
    return _userPhoto;
}


@end
