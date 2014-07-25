//
//  EditGuideViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 5/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "EditGuideViewController.h"
#import "GuideCategories.h"
#import "titleViewDelegate.h"
#import "stepEntryViewDelegate.h"
#import "UIImage+Resize.h"
#import "PFGuide.h"
#import "PFStep.h"
#import <Parse/Parse.h>
#import "DataEntryContainerViewController.h"
#import "DataEntryDelegate.h"
#import "SpokenGuideCache.h"

@interface EditGuideViewController () <UIActionSheetDelegate, UIAlertViewDelegate, DataEntryDelegate >

// view properties
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (nonatomic, weak)  DataEntryContainerViewController *containerViewController;
@property (weak, nonatomic) IBOutlet UIImageView *leftIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *rightIndicator;

// model properties
@property (strong, nonatomic) PFStep *stepInProgess;
@property BOOL advanceView;

@end

@implementation EditGuideViewController
{
    int stepNumber;
    swipeDirection transistionDirection;
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
    
    self.leftIndicator.hidden = YES;
    self.rightIndicator.hidden = YES;
    
    self.advanceView = YES;

}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.guideToEdit.title) {
        [self setLeftSwipe:YES];
    }

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
    NSLog(@"entryTextChanged");
    // User has entered or changed text data
    if (stepNumber == 0) {
            // changed the guide title
        if (!self.guideToEdit) {
            self.guideToEdit = [self createGuide];
            self.rightIndicator.hidden = NO;
        }
        if (![textEntry isEqualToString:self.guideToEdit.title]) {
            self.guideToEdit.title = textEntry;
            
            // notify delegate that text has changed
            if ([self.editGuideDelegate respondsToSelector:@selector(changedGuideUploading)]) {
                [self.editGuideDelegate changedGuideUploading];
            }
            
            [self.guideToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"guide uploaded due to title change");
                    if ([weakSelf.editGuideDelegate respondsToSelector:@selector(changedGuideFinishedUpload)]) {
                        [weakSelf.editGuideDelegate changedGuideFinishedUpload];
                    }
                }
                if (error) {
                    NSLog(@"error uploading guide to Parse");
                }
            }];
        }
    }
    else {
        // changed step instruction
        if (!self.stepInProgess) {
            self.stepInProgess = [self createStep];
            self.leftIndicator.hidden = NO;
            // make sure left swipe is enabled
            [self.leftSwipeGesture setEnabled:YES];
            NSLog(@"created step");
        }
        NSLog(@"TEXTENTRY %@ vs Instruction %@", textEntry, self.stepInProgess.instruction);
        if (![textEntry isEqualToString:self.stepInProgess.instruction]) {
            self.stepInProgess.instruction = textEntry;
            
            // add step to the cache
            [[SpokenGuideCache sharedCache] setAttributesForPFStep:self.stepInProgess
                                                      changedImage:nil
                                                  changedThumbnail:nil];
            // notify delegate that text has changed
            if ([self.editGuideDelegate respondsToSelector:@selector(changedStepUploading)]) {
                [self.editGuideDelegate changedStepUploading];
            }
            
            // Start the upload
            __block PFStep *stepToBeUploaded = self.stepInProgess;
            [stepToBeUploaded saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    PFRelation *relation = [weakSelf.guideToEdit relationForKey:@"pfSteps"];
                    [relation addObject:stepToBeUploaded];
                    [weakSelf.guideToEdit saveInBackground];
                    if ([weakSelf.editGuideDelegate respondsToSelector:@selector(changedStepFinishedUpload)]) {
                        [weakSelf.editGuideDelegate changedStepFinishedUpload];
                    }
                }
                if (error) {
                    NSLog(@"error uploading step to Parse");
                }
            }];
        }
    }
//    if (self.advanceView == YES) {
        // move to next data entry view
 //       [self leftSwipe:self.leftSwipeGesture];
 //   }
}

-(void)entryImageChanged:(UIImage *)imageEntry
{
    // User has added or changed image
    // Save a local copy until the upload is finished
    
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


    // upload the image files
    __weak typeof(self) _weakSelf = self;
    __block PFGuide *changedGuide;
    __block PFStep *changedStep;
    if (stepNumber == 0) {
        changedGuide = self.guideToEdit;
        changedStep = nil;
        // save updated images to cache
        NSMutableDictionary *guideAttributes = [[[SpokenGuideCache sharedCache] objectForKey:self.guideToEdit.objectId] mutableCopy];
        if (guideAttributes) {
            NSLog(@"guideAttributes %@", guideAttributes);
            [guideAttributes setValue:imageEntry forKey:kPFGuideChangedImage];
            [guideAttributes setValue:thumbnail forKey:kPFGuideChangedThumbnail];
            [[SpokenGuideCache sharedCache] setObject:[guideAttributes copy] forKey:self.guideToEdit.objectId];
        }

        // notify delegate that guide has changed
        if ([self.editGuideDelegate respondsToSelector:@selector(changedGuideUploading)]) {
            [self.editGuideDelegate changedGuideUploading];
        }
    }
    else {
        changedStep = self.stepInProgess;
        changedGuide = nil;
        // save updated images to cache
        NSMutableDictionary *stepAttributes = [[[SpokenGuideCache sharedCache] objectForKey:self.stepInProgess.objectId] mutableCopy];
        if (stepAttributes) {
        //    NSLog(@"stepAttributes %@", stepAttributes);
            [stepAttributes setValue:imageEntry forKey:kPFStepChangedImage];
            [stepAttributes setValue:thumbnail forKey:kPFStepChangedThumbnail];
            [[SpokenGuideCache sharedCache] setObject:[stepAttributes copy] forKey:self.stepInProgess.objectId];
        }
        
        // notify delegate of change
        [self.editGuideDelegate changedStepUploading];
    }
   // NSLog(@"starting image upload %@", imageFile);

    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded )
        {
            if ( (changedGuide && [changedGuide.objectId isEqual:_weakSelf.guideToEdit.objectId])
                || (changedStep && [changedStep.objectId isEqual:_weakSelf.stepInProgess.objectId]) ) {
                // let the view know to update with the image
                [_weakSelf.containerViewController.currentDataEntryVC imageLoaded:imageEntry];
            }

          //  NSLog(@"imageFile uploaded");
            [thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"thumbnailFile uploaded");
                    
                    // save PFFile's to guide
                    if (changedGuide) {
                        changedGuide.image = imageFile;
                        changedGuide.thumbnail = thumbnailFile;
                        [changedGuide saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                [_weakSelf.editGuideDelegate changedGuideFinishedUpload];
                            }
                           // NSLog(@"guide updated after image upload %@:  called delegate with change notice here", changedGuide);
                            if (error) {
                                NSLog(@"error uploading guide to Parse");
                            }
                        }];
                    }
                    else {
                        changedStep.image = imageFile;
                        changedStep.thumbnail = thumbnailFile;
                        [changedStep saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         //   int index = [changedStep.rank intValue]-1;
                            if (succeeded) {
                                [_weakSelf.editGuideDelegate changedStepFinishedUpload];
                            }
                          //  NSLog(@"STEP updated after image upload %@", changedStep);
                           //  [_weakSelf.guideToEdit.rankedStepsInGuide replaceObjectAtIndex:index withObject:changedStep];
                            if (error) {
                                NSLog(@"error uploading guide to Parse");
                            }
                        }];
                    }
                }
            } progressBlock:^(int percentDone) {
            //    NSLog(@"uploading percent done = %d", percentDone);
            }];
        }
    } progressBlock:^(int percentDone) {
     //   NSLog(@"uploading percent done = %d", percentDone);
    }];
 }


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
 //   self.advanceView = NO;
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma swipe gestures

-(void)setRightSwipe:(BOOL)activate
{
    self.rightSwipeGesture.enabled = activate;
    self.leftIndicator.hidden = !activate;
}

-(void)setLeftSwipe: (BOOL)activate
{
    self.leftSwipeGesture.enabled = activate;
    self.rightIndicator.hidden = !activate;
}

- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)sender {
// right swipe gesture will display either the title or an existing step but never a new step entry view
    transistionDirection = Right;
    NSLog(@"RIGHT SWIPE");
    // reactivate the left swipe gesture
    [self setLeftSwipe:YES];

    // about to leave the current view so make sure any changes are saved
    dispatch_queue_t updateQ = dispatch_queue_create("com.talkLists.update", NULL);
    dispatch_sync(updateQ, ^{
    //    self.advanceView = NO;
        [self.containerViewController.currentDataEntryVC viewAboutToChange];
    });
    
    // get the model data
    stepNumber -= 1;
    if (stepNumber >= 1) {
        // retreive the step from the model
        self.stepInProgess = [self.guideToEdit stepForRank:stepNumber];
        if (self.stepInProgess) {
            [self setContainerWithStep:self.stepInProgess];
        }
        else {
            NSLog(@"ERROR finding step in guide");
        }
    }
    else if (stepNumber == 0)
    {
        // retreive the guide
        if (self.guideToEdit) {
        //    self.containerViewController.entryText = self.guideToEdit.title;
            // check the cache for changes
            NSDictionary *guideAttributes = [[SpokenGuideCache sharedCache] objectForKey:self.guideToEdit.objectId];
            if (guideAttributes) {
                self.containerViewController.entryText = self.guideToEdit.title;
                UIImage *changedImage = [guideAttributes objectForKey:kPFGuideChangedImage];
                if (changedImage ) {
                    self.containerViewController.entryImage = changedImage;
                }
                else if (self.guideToEdit.image) {
                    self.containerViewController.entryImage = [UIImage imageNamed:@"image.png"];
                    [self.guideToEdit.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        [self.containerViewController.currentDataEntryVC imageLoaded:[UIImage imageWithData:data]];
                    }];
                }
                else {
                    self.containerViewController.entryImage = nil;
                }
            }
        }
        // stepNumber cannot go negative so disable rightSwipe
    //    sender.enabled = NO;
    //    self.leftIndicator.hidden = YES;
        [self setRightSwipe:NO];
    }
    
    // slide the new view in from the right
    self.containerViewController.entryTransistionDirection = transistionDirection;
    [self.containerViewController swapViewControllers];
}

- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)sender {
// left swipe gesture will display a current step with data or a new step entry view
    transistionDirection = Left;
    // reactivate right swipe gesture
    NSLog(@"LEFT SWIPE");
    [self setRightSwipe:YES];
 
    // about to leave the current view so make sure any changes are saved
    dispatch_queue_t updateQ = dispatch_queue_create("com.talkLists.update", NULL);
    dispatch_sync(updateQ, ^{
     //   self.advanceView = NO;
        [self.containerViewController.currentDataEntryVC viewAboutToChange];
    });

    // get the model data
    stepNumber += 1;
    // check if new step ?
    self.stepInProgess = [self.guideToEdit stepForRank:stepNumber];
    if (!self.stepInProgess) {
        // disable left swipe until new step is entered
      //  sender.enabled = NO;
     //   self.leftIndicator.hidden = YES;
        [self setLeftSwipe:NO];
     }
    // set up view with step data
    [self setContainerWithStep:self.stepInProgess];
    self.containerViewController.dataEntryDelegate = self;
    self.containerViewController.entryTransistionDirection = transistionDirection;
    [self.containerViewController swapViewControllers];

}

-(void)setContainerWithStep:(PFStep *)step
{
    if (step) {
        // check the cache for changes
        NSDictionary *stepAttributes = [[SpokenGuideCache sharedCache] objectForKey:step.objectId];
        if (stepAttributes) {
            PFStep *cachedStep = [stepAttributes objectForKey:kPFStepClassKey];
            self.containerViewController.entryText = cachedStep.instruction;
            UIImage *changedImage = [stepAttributes objectForKey:kPFStepChangedImage];
            if (changedImage ) {
                self.containerViewController.entryImage = changedImage;
            }
            else if (step.image) {
                self.containerViewController.entryImage = [UIImage imageNamed:@"image.png"];    // load the placeholder while the image is downloading
                [step.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    self.containerViewController.entryImage = [UIImage imageWithData:data];     // downloaded image put into containerViewController for data enty view controller to retreive
                    [self.containerViewController.currentDataEntryVC imageLoaded:[UIImage imageWithData:data]];     // let data entry controller know that the image is ready
                    }];
                }
            else {
                self.containerViewController.entryImage = nil;
            }
        }
        self.containerViewController.entryNumber = [self.stepInProgess.rank intValue];
    }
    else {
        // Set up view for new step
        self.containerViewController.entryText = nil;
        self.containerViewController.entryImage = nil;
        self.containerViewController.entryNumber = stepNumber;
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


#pragma mark Initializations

-(PFGuide *)createGuide
{

    PFGuide *newGuide = [PFGuide object];
    
    // set this guide's unique ID
    GuideCategories *cats = [[GuideCategories alloc] init];
    newGuide.classification = cats.categoryKeys[0];  // Set to default category and let the user change this if they want
    
    // add new guide to cache
    [[SpokenGuideCache sharedCache] setAttributesForPFGuide:newGuide
                                               changedImage:nil
                                           changedThumbnail:nil];
    return newGuide;
}


-(PFStep *)createStep
{
    PFStep *newStep = [PFStep object];

    newStep.rank = [NSNumber numberWithInt:stepNumber];
   // newStep.instruction = @"";
    [self.guideToEdit.rankedStepsInGuide addObject:newStep];
    
    // add new step to cache
    [[SpokenGuideCache sharedCache] setAttributesForPFStep:newStep
                                              changedImage:nil
                                          changedThumbnail:nil];
    return newStep;
}


@end
