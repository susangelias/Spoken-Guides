//
//  EditGuideViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 5/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "EditGuideViewController.h"
//#import "addPhotoViewController.h"
//#import "previewViewController.h"
//#import <MobileCoreServices/MobileCoreServices.h>
#import "GuideCategories.h"
#import "titleViewDelegate.h"
//#import "titleView.h"
#import "stepEntryViewDelegate.h"
//#import "stepView.h"
//#import "Step+Addendums.h"
//#import "Photo+Addendums.h"
//#import "SZTextView.h"
#import "UIImage+Resize.h"
#import "PFGuide.h"
#import "PFStep.h"
#import <Parse/Parse.h>
#import "DataEntryContainerViewController.h"
#import "DataEntryDelegate.h"

@interface EditGuideViewController () <UIActionSheetDelegate, UIAlertViewDelegate, DataEntryDelegate >

// view properties
//@property (weak, nonatomic) IBOutlet UITextField *guideTitle;
//@property (strong, nonatomic) titleView *guideTitleView;
//@property (weak, nonatomic) IBOutlet UIImageView *guideImageView;

//@property (weak, nonatomic) IBOutlet SZTextView *StepTextView;
//@property (strong, nonatomic) stepView *stepEntryView;
//@property (weak, nonatomic) IBOutlet SZTextView *swapTextView;
//@property (weak, nonatomic) IBOutlet UIImageView *stepImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *swapImageView;
//@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
//@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (nonatomic, weak)  DataEntryContainerViewController *containerViewController;

// model properties
@property (strong, nonatomic) PFStep *stepInProgess;
@property BOOL isChanged;

@end

@implementation EditGuideViewController
{
    int stepNumber;
}


#pragma mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    stepNumber = 0;
    
    // display the category
    self.categoryLabel.text = self.guideToEdit.classification;
     
    [self.navigationItem.leftBarButtonItem setTarget:self];
    [self.navigationItem.leftBarButtonItem setAction:@selector(doneButtonPressed:)];
    
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

#pragma mark <DataEntryDelegate>

-(void)entryTextChanged:(NSString *)textEntry
{
    __weak typeof(self) weakSelf = self;

    // User has entered or changed text data
    if (stepNumber == 0) {
            // changed the guide title
            self.guideToEdit.title = textEntry;
            [self.guideToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [weakSelf.editGuideDelegate guideObjectWasChanged:nil];
                }
                if (error) {
                    NSLog(@"error uploading guide to Parse");
                }
            }];
    }
    else {
        // changed step instruction
        self.stepInProgess.instruction = textEntry;
        [self.stepInProgess saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [weakSelf.editGuideDelegate guideObjectWasChanged:nil];
            }
            if (error) {
                NSLog(@"error uploading step to Parse");
            }
        }];
    }
    
}

-(void)entryImageChanged:(UIImage *)imageEntry
{
    // User has added or changed image
    if (stepNumber == 0) {
        // changed guide image
        // convert image to NSData
        NSData *imageData = UIImagePNGRepresentation(imageEntry);
        // then convert to PFFile for storing in Parse backend
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        
        // scale image to thumbnail size
        UIImage *thumbnail = [UIImage imageWithImage:imageEntry
                                        scaledToSize:CGSizeMake(69.0, 69.0)];
        // convert thumbnail to NSData
        NSData *thumbNailData = UIImagePNGRepresentation(thumbnail);
        // then convert to PFFile for storing in Parse backend
         PFFile *thumbnailFile = [PFFile fileWithName:@"thumbnail.png" data:thumbNailData];
        
        // save PFFile's to guide
        self.guideToEdit.image = imageFile;
        self.guideToEdit.thumbnail = thumbnailFile;
        [self.guideToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             if (error) {
                NSLog(@"error uploading guide to Parse");
            }
        }];
        
        // notify delegate of change and pass along image
        [self.editGuideDelegate guideObjectWasChanged:imageEntry];

   }
}

/*
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
    NSLog(@"%@", self.stepInProgess.instruction);
  //  if (![self.stepInProgess.instruction isEqualToString:instructionText]) {
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
   // }
}

-(void) stepInstructionEntryCompleted: (NSString *)instructionText
{
    [self stepInstructionEditingEnded:instructionText];
    
    // move on to the next step
    [self leftSwipe:self.leftSwipeGesture];
}

*/

#pragma mark Set Category Button

- (IBAction)setCategoryPressed
{
  //  [self.guideTitle resignFirstResponder];
  //  [self.StepTextView resignFirstResponder];
    
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
        [self.editGuideDelegate guideObjectWasChanged:nil];
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




#pragma swipe gestures

- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)sender {
// right swipe gesture will display either the title or an existing step but never a new step entry view
    // reactivate the left swipe gesture
    self.leftSwipeGesture.enabled = YES;

    // Save any final changes to the text into the model
 //   if (![self.stepEntryView.stepTextView.text isEqualToString:self.stepInProgess.instruction]) {
 //       self.stepInProgess.instruction = [NSString stringWithString:self.stepEntryView.stepTextView.text];
 //   }
    // get the model data
    stepNumber -= 1;
    if (stepNumber >= 1) {
        // retreive the step from the model
        self.stepInProgess = [self.guideToEdit stepForRank:stepNumber];
    }
    else if (stepNumber == 0)
    {
        // retreive the guide
        // stepNumber cannot go negative so
        // disable rightSwipe
        sender.enabled = NO;
    }
    
    // slide the new view in from the right
    [self.containerViewController swapViewControllers];
    /*
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
     */
}

- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)sender {
// left swipe gesture will display a current step with data or a new step entry view
    // reactivate right swipe gesture
    self.rightSwipeGesture.enabled = YES;
    
     // slide the title view off to the left
    /*
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
    */
    
    // get the model data
    stepNumber += 1;
    // check if new step ?
    self.stepInProgess = [self.guideToEdit stepForRank:stepNumber];
    if (!self.stepInProgess) {
        // no step found in guide for this step number so set up for a new step
      //  [self showPlaceHolderText];
        // disable left swipe until new step is entered
        sender.enabled = NO;
        // clear any images
        /*
        self.stepImageView.image = nil;
        self.swapImageView.image = nil;
        [self.stepEntryView updateLeftSwipeStepEntryView:nil
                                               withPhoto:nil];
        */
        self.containerViewController.entryText = nil;
        self.containerViewController.entryImage = nil;
        self.containerViewController.entryNumber = stepNumber;
        self.containerViewController.dataEntryDelegate = self;

        [self.containerViewController swapViewControllers];
    }
    else {
        // step is found so retreive photo
        if (self.stepInProgess.image) {
            PFImageView *imageView = [[PFImageView alloc] init];
            //   imageView.image = [UIImage imageNamed:@"..."];        // placeholder image
            imageView.file = (PFFile *)self.stepInProgess.image;  // remote image
            __weak typeof (self) weakSelf = self;
            [imageView loadInBackground:^(UIImage *image, NSError *error) {
           //     [weakSelf.stepEntryView updateLeftSwipeStepEntryView:weakSelf.stepInProgess.instruction
           //                                                withPhoto:image];
            }];
           }
        else {
        //    [self.stepEntryView updateLeftSwipeStepEntryView:self.stepInProgess.instruction
        //                                          withPhoto:nil];
        }
     
    }
}

- (IBAction)tapped:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self.view];
    UIView *touchedView = [self.view hitTest:touchPoint
                                   withEvent:nil];
    /*
    if (( ![touchedView isEqual:self.stepEntryView.stepTextView]) ||
        (![touchedView isEqual:self.stepEntryView.swapTextView]) ||
        (![touchedView isEqual:self.guideTitle]) ) {
        [self.stepEntryView.stepTextView resignFirstResponder];
        [self.guideTitle resignFirstResponder];
    } */
}


#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"embedContainer"]) {
      self.containerViewController = (DataEntryContainerViewController *)segue.destinationViewController;
      if (stepNumber == 0) {
          self.containerViewController.entryText = self.guideToEdit.title;
          self.containerViewController.entryImage = self.downloadedGuideImage;
      }
      self.containerViewController.dataEntryDelegate = self;
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
        /*
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
        } */
    }
}

    /*
-(void)showPlaceHolderText
{

    self.swapTextView.placeholder = [NSString stringWithFormat:@"Step %d\n\nEnter instructions here", stepNumber];
    self.StepTextView.placeholder = [NSString stringWithFormat:@"Step %d\n\nEnter instructions here", stepNumber];
   
}
     */

    /*
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
*/

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


@end
