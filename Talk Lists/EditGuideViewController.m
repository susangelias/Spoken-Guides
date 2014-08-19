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
#import "TalkListAppDelegate.h"

@interface EditGuideViewController () <UIActionSheetDelegate, UIAlertViewDelegate, DataEntryDelegate, UIGestureRecognizerDelegate >

// view properties
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (nonatomic, weak)  DataEntryContainerViewController *containerViewController;
@property (weak, nonatomic) IBOutlet UIImageView *leftIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *rightIndicator;

@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoryButton;

// model properties
@property (strong, nonatomic) PFStep *stepInProgess;


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

    self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
    
    // set view background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kAppBackgroundImageName]];

    // set self as gestureRecognizer delegate
    self.tapGesture.delegate = self;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.leftIndicator setFrame:CGRectMake(311.0f, 149.0f, 9.0f, 21.0f)];
    [self.rightIndicator setFrame:CGRectMake(0.0f, 149.0f, 9.0f, 21.0f)];
    
}
-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.guideToEdit.title) {
        [self setLeftSwipe:YES];
    }
    else {
        [self setLeftSwipe:NO];
        [self setRightSwipe:NO];
    }

 }


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
}

#pragma mark <DataEntryDelegate>

-(void)entryTextChanged:(NSString *)textEntry autoAdvance:(BOOL)advance
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
            // create a new step synchronously so that it will have an object ID when added to the cache below
            dispatch_queue_t updateQ = dispatch_queue_create("com.talkLists.createStep", NULL);
            dispatch_sync(updateQ, ^{
                self.stepInProgess = [self createStep];
            });
        }

        if (![textEntry isEqualToString:self.stepInProgess.instruction]) {
            [self.leftSwipeGesture setEnabled:YES];

            self.stepInProgess.instruction = textEntry;
            
            // update step in the cache
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
                if (succeeded && !error) {
                    NSLog(@"step uploaded %@", stepToBeUploaded );
                    PFRelation *relation = [weakSelf.guideToEdit relationForKey:@"pfSteps"];
                    [relation addObject:stepToBeUploaded];
                    [weakSelf.guideToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded && !error) {
                            if ([weakSelf.editGuideDelegate respondsToSelector:@selector(changedStepFinishedUpload)]) {
                                [weakSelf.editGuideDelegate changedStepFinishedUpload];
                            }
                        }
                    }];
                 }
                else  {
                    NSLog(@"error uploading step to Parse");
                }
            }];
        }
    }
    if (advance) {
        // move to next data entry view
        [self leftSwipe:self.leftSwipeGesture];
    }
}

-(void)entryImageChanged:(UIImage *)imageEntry
{
// User has added, changed or removed image
    
    if (!imageEntry) {
        // user has removed image
        [self entryImageRemoved];
        return;
    }
    
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
        if ([self.editGuideDelegate respondsToSelector:@selector(changedStepUploading)]) {
            [self.editGuideDelegate changedStepUploading];
        }
    }
   // NSLog(@"starting image upload %@", imageFile);

    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
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
                    NSLog(@"thumbnailFile uploaded: %@", thumbnailFile.name);
                    [[UIApplication sharedApplication] endBackgroundTask:_weakSelf.fileUploadBackgroundTaskId];
                    
                    // save PFFile's to guide
                    if (changedGuide) {
                        changedGuide.image = imageFile;
                        changedGuide.thumbnail = thumbnailFile;
                        [changedGuide saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                if ([_weakSelf.editGuideDelegate respondsToSelector:@selector(changedGuideFinishedUpload) ]) {
                                    [_weakSelf.editGuideDelegate changedGuideFinishedUpload];
                                }
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
                            if (succeeded) {
                                if ([_weakSelf.editGuideDelegate respondsToSelector:@selector(changedStepFinishedUpload)]) {
                                    [_weakSelf.editGuideDelegate changedStepFinishedUpload];
                                }
                            }
                          //  NSLog(@"STEP updated after image upload %@", changedStep);
                            if (error) {
                                NSLog(@"error uploading guide to Parse");
                            }
                        }];
                    }
                }
                else {
                    [[UIApplication sharedApplication] endBackgroundTask:_weakSelf.fileUploadBackgroundTaskId];
                }
            } progressBlock:^(int percentDone) {
            //    NSLog(@"uploading percent done = %d", percentDone);
            }];
        }
    } progressBlock:^(int percentDone) {
     //   NSLog(@"uploading percent done = %d", percentDone);
    }];
 }

-(void) entryImageRemoved
{
    // remove image and thumbnail from Parse using REST API
    NSString *imageFileNameToDelete;
    NSString *thumbnailFileNameToDelete;
    
    if (stepNumber == 0) {
        imageFileNameToDelete = self.guideToEdit.image.name;
        thumbnailFileNameToDelete = self.guideToEdit.thumbnail.name;
    }
    else {
        imageFileNameToDelete = self.stepInProgess.image.name;
        thumbnailFileNameToDelete = self.stepInProgess.thumbnail.name;
    }
    [self deletePFFile:imageFileNameToDelete];
    [self deletePFFile:thumbnailFileNameToDelete];
   
    
    // update parse object
    __weak typeof(self) _weakSelf = self;
    if (stepNumber == 0) {
        // guide photo removed
        self.guideToEdit.image = nil;
        self.guideToEdit.thumbnail = nil;
        [self.guideToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded && !error) {
                if ([_weakSelf.editGuideDelegate respondsToSelector:@selector(changedGuideFinishedUpload)]) {
                    [_weakSelf.editGuideDelegate changedGuideFinishedUpload];
                }
            }
        }];
    }
    else {
        // step photo removed
        self.stepInProgess.image = nil;
        self.stepInProgess.thumbnail = nil;
        [self.stepInProgess saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if ([_weakSelf.editGuideDelegate respondsToSelector:@selector(changedStepFinishedUpload)]) {
                [_weakSelf.editGuideDelegate changedStepFinishedUpload];
            }
        }];
    }
    
}

-(void)deletePFFile:(NSString *)fileName
{
    /*
     If you still want to delete a file, you can do so through the REST API. You will need to provide the master key in order to be allowed to delete a file. Note that the name of the file must be the name in the response of the upload operation, rather than the original filename.
     
     curl -X DELETE \
     -H "X-Parse-Application-Id: <YOUR_APPLICATION_ID>" \
     -H "X-Parse-Master-Key: <YOUR_MASTER_KEY>" \
     https://api.parse.com/1/files/<FILE_NAME>
     */
    
    NSString *endPoint = [NSString stringWithFormat:@"https://api.parse.com/1/files/%@", fileName];
    NSURL *url = [NSURL URLWithString:endPoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"-X DELETE"];
    [request setValue:kParseApplicationKey forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:kParseMasterKey forHTTPHeaderField:@"X-Parse-Master-Key"];
    
    NSLog(@"DELETING FILE: %@", fileName);
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   NSLog(@"FILE deletion error: %@, response: %@", connectionError, response);
                               }
                           }];
    
}

#pragma mark Set Category Button

- (IBAction)setCategoryPressed
{
    
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
        [self.guideToEdit saveInBackground];
    }
    else {
        // do nothing
        self.categoryLabel.text = @"";
    }
    
}

-(void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    
    // Change button colors from the standard blue to grey/black
    for (UIView *subView in actionSheet.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected] ;
        }
    }
}

#pragma  mark User Actions

- (IBAction)doneButtonPressed:(UIButton *)sender
{
    // about to leave the current view so make sure any changes are saved
    dispatch_queue_t updateQ = dispatch_queue_create("com.talkLists.resignFirstResponder", NULL);
    dispatch_sync(updateQ, ^{
        [self.containerViewController.currentDataEntryVC viewAboutToChange];
    });
    
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
        else {
            NSLog(@"error - cache is emtpy");
        }
        
        // stepNumber cannot go negative so disable rightSwipe
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
        [self.containerViewController.currentDataEntryVC viewAboutToChange];
    });

    // get the model data
    stepNumber += 1;
    // check if new step ?
    self.stepInProgess = [self.guideToEdit stepForRank:stepNumber];
    if (!self.stepInProgess) {
        // disable left swipe until new step is entered
        [self setLeftSwipe:NO];
     //   self.advanceView = NO;
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
        UIImage *changedImage = nil;
        NSDictionary *stepAttributes = [[SpokenGuideCache sharedCache] objectForKey:step.objectId];
        if (stepAttributes) {
            PFStep *cachedStep = [stepAttributes objectForKey:kPFStepClassKey];
            self.containerViewController.entryText = cachedStep.instruction;
            changedImage = [stepAttributes objectForKey:kPFStepChangedImage];
        }
        else {
            // step has not been added to the cache yet so just use what data is available in the PFStep input
            self.containerViewController.entryText = step.instruction;
        }
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
        self.containerViewController.entryNumber = [self.stepInProgess.rank intValue];
    }
    else {
        // Set up view for new step
        self.containerViewController.entryText = nil;
        self.containerViewController.entryImage = nil;
        self.containerViewController.entryNumber = stepNumber;
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // TAP Gesture recognizer will capture the touches in the toolbar unless we specifically let the button touch
    // through so that the IBAction can process it
    if ([touch.view.superview isKindOfClass:[UIToolbar class]]) {
        return FALSE;
    }
    else {
        return TRUE;
    }
}

- (IBAction)tapped:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self.view];
    UIView *touchedView = [self.view hitTest:touchPoint
                                   withEvent:nil];

    if (![touchedView isEqual:self.containerViewController.view]) {
        [self.containerViewController.currentDataEntryVC retractKeyboard];
    };

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
    newGuide.user = [PFUser currentUser];
    
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
    [self.guideToEdit.rankedStepsInGuide addObject:newStep];
        
    // upload new step to Parse
    [newStep saveInBackground];
    
    return newStep;
}


@end
