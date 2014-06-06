//
//  EditGuideViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 5/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "EditGuideViewController.h"
#import "addPhotoViewController.h"
#import "previewViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "GuideCategories.h"
#import "titleViewDelegate.h"
#import "titleView.h"
#import "stepEntryViewDelegate.h"
#import "stepView.h"
#import "Step+Addendums.h"
#import "Photo+Addendums.h"
#import "SZTextView.h"

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
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;

// model properties
@property (strong, nonatomic) Step *stepInProgess;
@property (strong, nonatomic) Photo *userPhoto;

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
    
    // set up the guide's photo if there is one
//    [self.guideTitle addSubview:self.guideImageView];
//    self.guideImageView.image = [UIImage imageWithData:self.guideToEdit.photo.thumbnail];
   
    // make sure step text views are hidden to start with
    self.StepTextView.hidden = YES;
    self.swapTextView.hidden = YES;
    self.swapImageView.hidden = YES;
    self.stepImageView.hidden = YES;
    
    stepNumber = 0;
  //  self.showSaveAlert = NO;
    
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
    
    if (self.guideToEdit) {
        [self.managedObjectContext.undoManager beginUndoGrouping];
    }
    
    // create the stepEntryView here so that it gets laid out correctly
    [self stepEntryView];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (stepNumber == 0) {
        [self.guideTitleView updateStaticTitleEntryView:self.guideToEdit.title
                                              withPhoto:[UIImage imageWithData:self.guideToEdit.photo.thumbnail]];
    }
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
        // only create guide if the title string is not an empty string
        // if this is a new guide - create the guide object once a title has been entered
        if (!self.guideToEdit) {
            self.guideToEdit= [self createGuide];
        }
        
        self.guideToEdit.title = title;
        self.navigationItem.title = title;
      //  self.showSaveAlert = YES;
   
        // move to the first step view
        [self leftSwipe:self.leftSwipeGesture];
    }

}

#pragma mark <stepEntryViewDelegate>

-(void) stepInstructionTextChanged: (NSString *)instructionText
{
    if (![instructionText isEqualToString:@""])
    {
        if (!self.stepInProgess) {
            self.stepInProgess = [self createStep];
        }
    }
}

-(void) stepInstructionEditingEnded: (NSString *)instructionText
{
    // save current instructions in model
    if (![self.stepInProgess.instruction isEqualToString:instructionText]) {
        self.stepInProgess.instruction = instructionText;
    }
}

-(void) stepInstructionEntryCompleted: (NSString *)instructionText
{
    [self stepInstructionEditingEnded:instructionText];
    
    // update user's onscreen instructions
    stepNumber++;
    self.stepInProgess = [self.guideToEdit stepForRank:stepNumber];
    [self showPlaceHolderText];
    
    // clear any images
    self.stepImageView.image = nil;
    self.swapImageView.image = nil;
    // update the view
    [self.stepEntryView updateLeftSwipeStepEntryView:self.stepInProgess.instruction
                                      withPhoto:[UIImage imageWithData:self.stepInProgess.photo.thumbnail]];
    
    // clear the photo image
    self.userPhoto = nil;   // release pointer to current step's photo core data object which will force a new photo object to be created when the user take's or chooses another photo
    
    // make sure right swipe is active again
    self.rightSwipeGesture.enabled = YES;
}

#pragma mark Add Photo unwind segues

- (IBAction)photoAdded:(UIStoryboardSegue *)segue
{
    addPhotoViewController *addPhotoVC = (addPhotoViewController *)segue.sourceViewController;
    
    if (addPhotoVC.assetLibraryURL) {
     //   self.userPhoto.assetLibraryURL = [addPhotoVC.assetLibraryURL absoluteString];
        __weak typeof (self) weakSelf = self;
        // Retreive the thumbnail of the photo so it can be displayed in the delegate method
        [addPhotoVC.library getThumbNailForAssetURL:[NSURL URLWithString:[addPhotoVC.assetLibraryURL absoluteString]]
                                withCompletionBlock:^(UIImage *image, NSError *error) {
                                    // Create a new photo object and save 
                                    Photo *newPhoto = [weakSelf createPhoto];
                                    newPhoto.thumbnail = UIImagePNGRepresentation(image);
                                    newPhoto.assetLibraryURL = [addPhotoVC.assetLibraryURL absoluteString];

                                    if (weakSelf.guideTitle.hidden == NO) {
                                        // title view is showing so this photo belongs to the guide
                                        if (!weakSelf.guideToEdit) {
                                            // create guide if we don't have one yet
                                            weakSelf.guideToEdit = [weakSelf createGuide];
                                        }
                                        weakSelf.guideToEdit.photo = newPhoto;
                                    }
                                    else {
                                        // step view is showing so this photo belongs to the current step
                                        weakSelf.stepInProgess.photo = newPhoto;
                                    }
                                    
                                    // display thumbail on this screen
                                    if (weakSelf.guideTitle.hidden == YES) {
                                        weakSelf.stepImageView.image = image;
                                        weakSelf.stepImageView.hidden = NO;
                                     //   weakSelf.swapImageView.image = image;
                                    }
                                    else {
                                        weakSelf.guideImageView.image = image;
                                    }
                                }];
    }
    // resume editing of step text
 //   [self resetFirstResponder];
    
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
        self.guideToEdit.title = self.guideTitle.text;
    }
    
    NSLog(@"inserted objects %@", [self.managedObjectContext insertedObjects]);
    NSLog(@"deleted objects %@", [self.managedObjectContext deletedObjects]);
    NSLog(@"has changes %hhd", [self.managedObjectContext hasChanges]);

    //  put up the alert to save any changes made to the guide
    if ([self.managedObjectContext hasChanges] == YES )
    {
     
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finish Guide"
                                                        message:@"Do you want to save your guide ?\n(You can choose to publish it later from the Browse screen.)"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Save",@"Discard Changes", nil];
        [alert show];
    }
    else {
        // otherwise simply return to main screen without saving anything because the user hasn't entered anythig
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
     if ( (!buttonIndex == 0) && (self.guideToEdit) )
    {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (buttonIndex == 1) {
            // save guide to core data
            NSError *error;
            [self.managedObjectContext save:&error];
            if (error) {
                NSLog(@"ERROR saving context: %@", error);
            }
        }
        else if (buttonIndex == 2) {
            // undo any changes
            if ([self.managedObjectContext.undoManager canUndo]) {
                [self.managedObjectContext.undoManager undoNestedGroup];
            }
        }
        NSLog(@"inserted objects %@", [self.managedObjectContext insertedObjects]);
        NSLog(@"deleted objects %@", [self.managedObjectContext deletedObjects]);
        NSLog(@"has changes %hhd", [self.managedObjectContext hasChanges]);
        
        // return to main screen
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma swipe gestures

- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)sender {
// right swipe gesture will display either the title or an existing step but never a new step entry view
    // reactivate the left swipe gesture
    self.leftSwipeGesture.enabled = YES;

    // Save any final changes to the text into the model
    self.stepInProgess.instruction = self.stepEntryView.stepTextView.text;
 
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
        [self.stepEntryView updateRightSwipeStepEntryView:self.stepInProgess.instruction
                                           withPhoto:[UIImage imageWithData:self.stepInProgess.photo.thumbnail]];
    }
    else if (stepNumber == 0) {
        // slide the step view off to the left
        [self.stepEntryView hideStepEntryView];
        
        // show the title view
        [self.guideTitleView updateRightSwipeTitleEntryView:self.guideToEdit.title
                                     withPhoto:[UIImage imageWithData:self.guideToEdit.photo.thumbnail]];
    }
}

- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)sender {
// left swipe gesture will display a current step with data or a new step entry view
    // reactivate right swipe gesture
    self.rightSwipeGesture.enabled = YES;
    
     // slide the title view off to the left
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
    }

    // update view with new data
    [self.stepEntryView updateLeftSwipeStepEntryView:self.stepInProgess.instruction
                                      withPhoto:[UIImage imageWithData:self.stepInProgess.photo.thumbnail]];
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
    if ([segue.identifier isEqualToString:@"previewSegue"] )
    {
        if ([[segue destinationViewController] isKindOfClass:[previewViewController class]]) {
            previewViewController *destController = [segue destinationViewController];
            destController.guideToPreview = self.guideToEdit;
            if (self.guideTitle.hidden == NO) {
                // show title in progress in preview
                destController.titleToPreview = self.guideTitle.text;
            } else  {
                // update in progress step to model even if user has not hit the Next key yet
                self.stepInProgess.instruction = self.stepEntryView.stepTextView.text;
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"addPhotoSegue"] ) {
        if ([[segue destinationViewController] isKindOfClass:[addPhotoViewController class]]) {
            addPhotoViewController *destController = [segue destinationViewController];
            destController.albumName = self.guideToEdit.uniqueID;
        }
        
    }
}


#pragma mark Helpers
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

-(Guide *)createGuide
{
        [self.managedObjectContext.undoManager beginUndoGrouping];
        Guide *newGuide = [Guide insertNewObjectInManagedObjectContext:self.managedObjectContext];

        // set this guide's unique ID
#warning add user's ID to the uniqueID string
        newGuide.uniqueID = [NSString stringWithFormat:@"Talk Notes %d", rand()];
        GuideCategories *cats = [[GuideCategories alloc] init];
        newGuide.classification = cats.categoryKeys[0];  // Set to default category and let the user change this if they want
        newGuide.creationDate = [NSDate dateWithTimeIntervalSinceNow:0];
    return newGuide;
}


-(Step *)createStep
{
    Step *newStep = [Step insertNewObjectInManagedObjectContext:self.managedObjectContext];
    newStep.rank = [NSNumber numberWithInt:stepNumber];
    [self.guideToEdit addStepInGuideObject:newStep];
    return newStep;
}

-(Photo *)createPhoto
{
    Photo *newPhoto = [Photo insertNewObjectInManagedObjectContext:self.managedObjectContext];
    return newPhoto;
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
