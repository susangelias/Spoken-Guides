//
//  EditGuideViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 5/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "EditGuideViewController.h"
#import "addPhotoViewController.h"
//#import "previewViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "GuideCategories.h"
#import "titleViewDelegate.h"
#import "titleView.h"
#import "stepEntryViewDelegate.h"
#import "stepView.h"
//#import "Step+Addendums.h"
//#import "Photo+Addendums.h"
#import "SZTextView.h"
#import "UIImage+Resize.h"
#import "PFGuide.h"
#import "PFStep.h"
#import <Parse/Parse.h>

@interface EditGuideViewController () <UIActionSheetDelegate, UIAlertViewDelegate, titleViewDelegate, stepViewDelegate >

// view properties
@property (weak, nonatomic) IBOutlet UITextField *guideTitle;
@property (strong, nonatomic) titleView *guideTitleView;
@property (weak, nonatomic) IBOutlet UIImageView *guideImageView;

@property (weak, nonatomic) IBOutlet SZTextView *StepTextView;
@property (strong, nonatomic) stepView *stepEntryView;
@property (weak, nonatomic) IBOutlet SZTextView *swapTextView;
@property (weak, nonatomic) IBOutlet UIImageView *stepImageView;
@property (weak, nonatomic) IBOutlet UIImageView *swapImageView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
//@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;

// model properties
@property (strong, nonatomic) PFStep *stepInProgess;
@property BOOL isChanged;

@end

@implementation EditGuideViewController
{
    int stepNumber;
    SZTextView *TEMP;
}


#pragma mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        TEMP = [[SZTextView alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up guide title entry view
    self.guideTitleView = [[titleView alloc] initWithTextField:self.guideTitle
                                                 withImageView:self.guideImageView];
    self.guideTitleView.guideTitleDelegate = self;
    
    // make sure step text views are hidden to start with
    self.StepTextView.hidden = YES;
    self.swapTextView.hidden = YES;
    self.swapImageView.hidden = YES;
    self.stepImageView.hidden = YES;
    
    stepNumber = 0;
    
    // display the category
    self.categoryLabel.text = self.guideToEdit.classification;

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
    
    // create the stepEntryView here so that it gets laid out correctly
    [self stepEntryView];
    
    self.isChanged = NO;

}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    BOOL titleAnimated = NO;
    [self showTitle:titleAnimated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
}

#pragma mark <titleViewDelegate>

-(void)titleCompleted:(NSString*)title
{

    if (![title isEqualToString:@""]) {
        [self saveTitleToModel:title];
        self.navigationItem.title = title;
   
        // move to the first step view
        [self leftSwipe:self.leftSwipeGesture];
    }

}

#pragma mark <stepEntryViewDelegate>

-(void) stepInstructionTextChanged: (NSRange)range withReplacementText:(NSString *)replacementInstructionText
{
        if (!self.stepInProgess) {
            self.stepInProgess = [self createStep];
        }
        // replace text in model
        if (self.stepInProgess)
        {
            NSString * currentInstruction = self.stepInProgess.instruction;
            if (self.stepInProgess.instruction) {
                self.stepInProgess.instruction = [currentInstruction stringByReplacingCharactersInRange:range
                                                                    withString:replacementInstructionText];
            }
        }
}

-(void) stepInstructionEditingEnded: (NSString *)instructionText
{
    // save current instructions in model
    if (![self.stepInProgess.instruction isEqualToString:instructionText]) {
        self.stepInProgess.instruction = [NSString stringWithString:instructionText];
        // save to parse
        __weak typeof(self) weakSelf = self;
        [self.stepInProgess saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [weakSelf.guideToEdit addObject:weakSelf.stepInProgess
                                         forKey:@"pfSteps"];
                weakSelf.isChanged = YES;
            }
        }];
    }
}

-(void) stepInstructionEntryCompleted: (NSString *)instructionText
{
    [self stepInstructionEditingEnded:instructionText];
    
    // move on to the next step
    [self leftSwipe:self.leftSwipeGesture];
}

#pragma mark Add Photo unwind segues

- (IBAction)photoAdded:(UIStoryboardSegue *)segue
{
    addPhotoViewController *addPhotoVC = (addPhotoViewController *)segue.sourceViewController;
 
    if (addPhotoVC.selectedPhoto) {
        // convert image to NSData
        NSData *imageData = UIImagePNGRepresentation(addPhotoVC.selectedPhoto);
        // then convert to PFFile for storing in Parse backend
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    
        PFFile *thumbnailFile = nil;
        if (addPhotoVC.selectedThumbnail) {
            // convert thumbnail to NSData
            NSData *thumbNailData = UIImagePNGRepresentation(addPhotoVC.selectedThumbnail);
            // then convert to PFFile for storing in Parse backend
            thumbnailFile = [PFFile fileWithName:@"thumbnail.png" data:thumbNailData];
        }
        
        // associate photo  with a guide or step object
        if (self.guideTitle.hidden == NO) {
            // title view is showing so this photo belongs to the guide
            if (!self.guideToEdit) {
                // create guide if we don't have one yet
                self.guideToEdit = [self createGuide];
            }
            if (self.guideToEdit.image) {
                // need to remove previous photo object
              //  WITH PARSE THIS HAS TO BE DONE THROUGH THE REST API
            }
            self.guideToEdit.image = imageFile;
            self.guideToEdit.thumbnail = thumbnailFile;
            [self.guideToEdit saveInBackground];
            self.isChanged = YES;
            }
        else {
            // step view is showing so this photo belongs to the current step
            if (self.stepInProgess.image) {
                // need to remove previous photo object
                //  WITH PARSE THIS HAS TO BE DONE THROUGH THE REST API
            }
            self.stepInProgess.image = imageFile;
            self.stepInProgess.thumbnail = thumbnailFile;
            [self.stepInProgess saveInBackground];
            self.isChanged = YES;
        }
        
        // update the screen display with the full image, not the thumbnail
        if (self.guideTitle.hidden == YES) {
            // update the step image view
            self.stepImageView.image = addPhotoVC.selectedPhoto;
            self.stepImageView.hidden = NO;
        }
        else {
            // update the guide image view
            self.guideImageView.image = addPhotoVC.selectedPhoto;
            self.guideImageView.hidden = NO;
        }

      }
    addPhotoVC.selectedPhoto = nil;
    addPhotoVC.selectedThumbnail = nil;
    
}

- (IBAction)photoCanceled:(UIStoryboardSegue *)segue
{
    // resume editing of step text
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
        self.guideToEdit.classification = choice;
        self.categoryLabel.text = choice;
    }
    else {
        // do nothing
        self.categoryLabel.text = @"";
    }
    
}


#pragma  mark User Actions

- (IBAction)doneButtonPressed:(UIButton *)sender
{
    // save the most recent text view where the user has typed in text but not pressed the Next key
    if (![self.guideToEdit.title isEqualToString:self.guideTitle.text]) {
        // this title needs to be saved to model
        [self saveTitleToModel:self.guideTitle.text];
    }
    

    //  put up the alert to save any changes made to the guide
  //  __block BOOL isDirty = NO;
    if ([self.guideToEdit isDirty]) {
        self.isChanged = YES;
        [self.guideToEdit saveInBackground];
    }
    else {
        [self.guideToEdit.rankedStepsInGuide enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PFStep *step = (PFStep *)obj;
            if ([step isDirty]) {
                self.isChanged = YES;
                *stop = YES;
                [step saveInBackground];
            }
        }];
    }

    if (self.isChanged)
    {
        [self.editGuideDelegate guideObjectWasChanged];
    }
    /*
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finish Guide"
                                                        message:@"Do you want to save your guide ?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Save",@"Discard Changes", nil];
        [alert show];
     
        
    }
    else { */
        // otherwise simply return to main screen without saving anything because the user hasn't entered anythig
        [self.navigationController popViewControllerAnimated:YES];
  //  }
}

/*
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
     if ( (!buttonIndex == 0) && (self.guideToEdit) )
    {
     //   [self.managedObjectContext.undoManager endUndoGrouping];
        __weak typeof(self) weakSelf = self;
        if (buttonIndex == 1) {
            // SAVE: save guide to Parse backend
            [self.guideToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    weakSelf.guideToEdit.uniqueID = weakSelf.guideToEdit.objectId;
                    // save all the steps to back end
                    if ([weakSelf.guideToEdit.rankedStepsInGuide count ] > 0) {
                        [self.guideToEdit.rankedStepsInGuide enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            PFStep *stepToSave = (PFStep *)obj;
                            if ([stepToSave isDirty]) {
                                [stepToSave saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (succeeded) {
                                        [weakSelf.guideToEdit.pfSteps addObject:stepToSave];
                                        [weakSelf.guideToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            if (idx+1 == [weakSelf.guideToEdit.rankedStepsInGuide count]) {
                                                [self.editGuideDelegate guideObjectWasChanged];
                                                [weakSelf.navigationController popViewControllerAnimated:YES];
                                            }
                                        }];
                                    }
                                    if (error) {
                                        NSLog(@"error publishing step %@", error);
                                    }
                                }];
                            }
                            else if (idx+1 == [weakSelf.guideToEdit.rankedStepsInGuide count]) {
                                [self.editGuideDelegate guideObjectWasChanged];
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                            }
                        }];
                    }
                    else {
                        [self.editGuideDelegate guideObjectWasChanged];
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }
                if (error) {
                    NSLog(@"error publishing guide %@", error);
                }
            }];
          }
        else if (buttonIndex == 2) {
            // DISCARD:  undo any changes
            // refresh view from model for the step that is displayed
             self.StepTextView.text = self.swapTextView.text = self.stepInProgess.instruction;
            [self.navigationController popViewControllerAnimated:YES];
        }
          
     }
}
 */
/*

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( (!buttonIndex == 0) && (self.guideToEdit) )
    {
        __weak typeof(self) weakSelf = self;
        if (buttonIndex == 1) {
            // SAVE:
            // First save all the steps
            [self.guideToEdit.rankedStepsInGuide enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PFStep *stepToSave = (PFStep *)obj;
                if ([stepToSave isDirty]) {
                    [stepToSave saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [weakSelf.guideToEdit.pfSteps addObject:stepToSave];
                    }];
                }
            }];

            // Next, save the guide to Parse backend
            [self.guideToEdit saveInBackground];
            
            // Notify parent controller that guide has changed
            [self.editGuideDelegate guideObjectWasChanged];
        }
        else if (buttonIndex == 2) {
            // DISCARD:  undo any changes
            // refresh view from model for the step that is displayed
            self.StepTextView.text = self.swapTextView.text = self.stepInProgess.instruction;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
*/

#pragma swipe gestures

- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)sender {
// right swipe gesture will display either the title or an existing step but never a new step entry view
    // reactivate the left swipe gesture
    self.leftSwipeGesture.enabled = YES;

    // Save any final changes to the text into the model
    if (![self.stepEntryView.stepTextView.text isEqualToString:self.stepInProgess.instruction]) {
        self.stepInProgess.instruction = [NSString stringWithString:self.stepEntryView.stepTextView.text];
    }
    // get the model data
    stepNumber -= 1;
    if (stepNumber >= 1) {
        // retreive the step from the model
        self.stepInProgess = [self.guideToEdit stepForRank:stepNumber];
    }
    else if (stepNumber == 0)
    {
        // stepNumber cannot go negative so
        // disable rightSwipe
        sender.enabled = NO;
    }
    
    // slide the new view in from the right
    if (stepNumber > 0) {
        // step is found so retreive photo
        if (self.stepInProgess.image) {
            PFImageView *imageView = [[PFImageView alloc] init];
         //   imageView.image = [UIImage imageNamed:@"..."];        // placeholder image
            imageView.file = (PFFile *)self.stepInProgess.image;  // remote image
            
           // [imageView loadInBackground];
            __weak typeof (self) weakSelf = self;
            [imageView loadInBackground:^(UIImage *image, NSError *error) {
                [weakSelf.stepEntryView updateRightSwipeStepEntryView:weakSelf.stepInProgess.instruction
                                                            withPhoto:image];
            }];
        }
        else {
            [self.stepEntryView updateRightSwipeStepEntryView:self.stepInProgess.instruction
                                                   withPhoto:nil];
        }
    }
    else if (stepNumber == 0) {
        // slide the step view off to the left
        [self.stepEntryView hideStepEntryView];
        
        // show the title view
        BOOL titleAnimated = YES;
        [self showTitle:titleAnimated];
    }
}

- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)sender {
// left swipe gesture will display a current step with data or a new step entry view
    // reactivate right swipe gesture
    self.rightSwipeGesture.enabled = YES;
    
     // slide the title view off to the left
    if ( (!self.guideToEdit) && (![self.guideTitle.text isEqualToString:@""]) )
    {
        // user entered a title then left swiped instead of pressing the Next key
        // so make sure title is saved to the guide
        [self saveTitleToModel:self.guideTitle.text];
    }
    if (stepNumber == 0) {
        // hide the title screen
        [self.guideTitleView hideTitleView];
    }
    
    // get the model data
    stepNumber += 1;
    // check if new step ?
    self.stepInProgess = [self.guideToEdit stepForRank:stepNumber];
    if (!self.stepInProgess) {
        // no step found in guide for this step number so set up for a new step
        [self showPlaceHolderText];
        // disable left swipe until new step is entered
        sender.enabled = NO;
        // clear any images
        self.stepImageView.image = nil;
        self.swapImageView.image = nil;
        [self.stepEntryView updateLeftSwipeStepEntryView:nil
                                               withPhoto:nil];
    }
    else {
        // step is found so retreive photo
        if (self.stepInProgess.image) {
            PFImageView *imageView = [[PFImageView alloc] init];
            //   imageView.image = [UIImage imageNamed:@"..."];        // placeholder image
            imageView.file = (PFFile *)self.stepInProgess.image;  // remote image
            
            // [imageView loadInBackground];
            __weak typeof (self) weakSelf = self;
            [imageView loadInBackground:^(UIImage *image, NSError *error) {
                [weakSelf.stepEntryView updateLeftSwipeStepEntryView:weakSelf.stepInProgess.instruction
                                                           withPhoto:image];
            }];
           }
        else {
            [self.stepEntryView updateLeftSwipeStepEntryView:self.stepInProgess.instruction
                                                   withPhoto:nil];
        }
     
    }
}

- (IBAction)tapped:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self.view];
    UIView *touchedView = [self.view hitTest:touchPoint
                                   withEvent:nil];
    if (( ![touchedView isEqual:self.stepEntryView.stepTextView]) ||
        (![touchedView isEqual:self.stepEntryView.swapTextView]) ||
        (![touchedView isEqual:self.guideTitle]) ) {
        [self.stepEntryView.stepTextView resignFirstResponder];
        [self.guideTitle resignFirstResponder];
    }
}


#pragma mark Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"addPhotoSegue"] ) {
        if ([[segue destinationViewController] isKindOfClass:[addPhotoViewController class]]) {
         //   addPhotoViewController *destController = [segue destinationViewController];
        //    destController.albumName = self.guideToEdit.uniqueID;
        }
        
    }
}


#pragma mark Helpers

-(void)saveTitleToModel:(NSString *)title
{
    // if this is a new guide - create the guide object once a title has been entered
    if (!self.guideToEdit) {
        self.guideToEdit= [self createGuide];
    }
    
    self.guideToEdit.title = title;
    [self.guideToEdit saveInBackground];    // save to Parse backend
}

-(void)showTitle:(BOOL)animated
{
    if (stepNumber == 0) {
        if (self.guideToEdit.image) {
            PFImageView *guideImageView = [[PFImageView alloc] init];
            guideImageView.file = self.guideToEdit.image;
            __weak typeof (self) weakSelf = self;
            [guideImageView loadInBackground:^(UIImage *image, NSError *error) {
                if (animated) {
                    [weakSelf.guideTitleView updateRightSwipeTitleEntryView:weakSelf.guideToEdit.title
                                                              withPhoto:image];
                }
                else {
                    [weakSelf.guideTitleView updateStaticTitleEntryView:weakSelf.guideToEdit.title
                                                          withPhoto:image];
                }
            }];
         }
        else {
            if (animated) {
                [self.guideTitleView updateRightSwipeTitleEntryView:self.guideToEdit.title
                                                          withPhoto:nil];
            }
            else {
                [self.guideTitleView updateStaticTitleEntryView:self.guideToEdit.title
                                                  withPhoto:nil];
            }
        }
    }
}

-(void)showPlaceHolderText
{

    self.swapTextView.placeholder = [NSString stringWithFormat:@"Step %d\n\nEnter instructions here", stepNumber];
    self.StepTextView.placeholder = [NSString stringWithFormat:@"Step %d\n\nEnter instructions here", stepNumber];
   
}

-(void)resetFirstResponder {
    __weak typeof (self) weakSelf = self;
    if (self.StepTextView.hidden == NO) {
        [UIView animateWithDuration:0.0     // move to stepView class
                         animations:^{
                             [weakSelf.view addSubview:weakSelf.StepTextView];
                         }
                         completion:^(BOOL finished) {
                             [weakSelf.StepTextView becomeFirstResponder];
                         }
         ];
    }
    else if (self.guideTitle.hidden == NO) {
        self.guideTitle.clearsOnBeginEditing = NO;  // move to titleView class
        [UIView animateWithDuration:0.0
                         animations:^{
                             [weakSelf.view addSubview:weakSelf.guideTitle];
                         }
                         completion:^(BOOL finished) {
                             [weakSelf.guideTitle becomeFirstResponder];
                         }
         ];
        
    }
    
}


#pragma mark Initializations

-(PFGuide *)createGuide
{

    PFGuide *newGuide = [PFGuide object];
    
    // set this guide's unique ID
#warning add user's ID to the uniqueID string
    newGuide.uniqueID = [NSString stringWithFormat:@"Talk Notes %d", rand()];
    GuideCategories *cats = [[GuideCategories alloc] init];
    newGuide.classification = cats.categoryKeys[0];  // Set to default category and let the user change this if they want
    newGuide.creationDate = [NSDate dateWithTimeIntervalSinceNow:0];

    return newGuide;
}


-(PFStep *)createStep
{
    PFStep *newStep = [PFStep object];

    newStep.rank = [NSNumber numberWithInt:stepNumber];
    newStep.instruction = @"";
    [self.guideToEdit.rankedStepsInGuide addObject:newStep];
    return newStep;
}



-(stepView *)stepEntryView
{
    if (!_stepEntryView ) {
        _stepEntryView = [[stepView alloc]initWithPrimaryTextView:self.StepTextView
                                                secondaryTextView: self.swapTextView
                                             withPrimaryImageView:self.stepImageView
                                           withSecondaryImageView:self.swapImageView];
        _stepEntryView.stepEntryDelegate = self;
    }
    return _stepEntryView;
}


@end
