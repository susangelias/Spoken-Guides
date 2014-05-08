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

@interface NewGuideViewController () <UIActionSheetDelegate, UIAlertViewDelegate, titleViewDelegate, stepEntryViewDelegate >

// view properties
@property (weak, nonatomic) IBOutlet UITextField *guideTitle;
@property (strong, nonatomic) titleView *guideTitleView;

@property (weak, nonatomic) IBOutlet UILabel *UserDirections;

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
    NSLog(@"title entered: %@", title);
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
                         } completion:^(BOOL finished) {
                             Nil;
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
    NSLog(@"step instruction:  %@", instructionText);
    // save instructions in model
    self.stepInProgess.instruction = instructionText;
    
    // update user's onscreen instructions
    [self updateStepText];
    
    // clear the photo image
       self.imageView.image = nil;
}

- (IBAction)photoAdded:(UIStoryboardSegue *)segue
{
    addPhotoViewController *apVC = (addPhotoViewController *)segue.sourceViewController;
    // get the image from modal vc
    UIImage *photo;
    photo = apVC.photo;
    if (photo) {
        // save photo to model
        
        // Display thumbnail of photo
        self.imageView.image =  photo;
    }
 
    // resume editing of step text
    [self resetFirstResponder];
 
}

- (IBAction)photoCanceled:(UIStoryboardSegue *)segue
{
    // resume editing of step text
    [self resetFirstResponder];
}

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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finish Guide"
                                                    message:@"Choose where to save your guide"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save Local", @"Publish", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex == 0)
    {
        // save choice to model
        
        // save guide to core data
        if (self.guideInProgress.title) {
            NSError *error;
            [self.managedObjectContext save:&error];
            if (error) {
                NSLog(@"ERROR saving context: %@", error);
            }
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
    self.UserDirections.text = [NSString stringWithFormat:@"Step %d", stepNumber];
    
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


@end
