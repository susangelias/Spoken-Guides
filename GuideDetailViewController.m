//
//  GuideDetailViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideDetailViewController.h"
#import "BlurryModalSegue.h"
#import "dialogController.h"
#import "TalkListAppDelegate.h"
#import "EditGuideViewController.h"
#import "EditGuideViewControllerDelegate.h"
#import "PFStep.h"
#import "GuideQueryTableViewController.h"
#import "GuideQueryTableViewControllerDelegate.h"
#import "SpokenGuideCache.h"

typedef NS_ENUM(NSInteger, dialogState) {
    isPlaying,
    isPaused,
    isReset
};

NSString * const kHighlightColor = @"AppleGreen";

@interface GuideDetailViewController () < dialogControllerDelegate, GuideQueryTableViewControllerDelegate, EditGuideViewControllerDelegate, UIAlertViewDelegate>

// View properties
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet PFImageView *guidePicture;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *statusDisplay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, strong) NSArray *stateStrings;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelAlternate;
@property int selectedRowNumber;

@property (strong, nonatomic) dialogController  *dialogController;
@property dialogState currentState;
@property (strong, nonatomic) AVAudioSessionRouteDescription *originalAudioRoute;
@property BOOL routeChangeInProcess;


@end

@implementation GuideDetailViewController

#pragma mark View lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // instantiate dialog controller now rather than waiting until the user presses the Play
    // button as it takes 2 secs to initialize speech recognition model
    if (!self.dialogController) {
        self.dialogController = [[dialogController alloc] init];
        if (self.dialogController) {
            self.dialogController.dialogControlDelegate = self;
        }
    }

}


- (void)viewDidLoad
{
    [super viewDidLoad];

   
    // set view background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kAppBackgroundImageName]];

   // set text color for status display
    self.statusDisplay.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kHighlightColor]];
    
    self.routeChangeInProcess = NO;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    // get a copy of the latest guide attributes from the cache
    NSDictionary *guideAttributes = [[SpokenGuideCache sharedCache] objectForKey:self.guide.objectId];
    UIImage *changedImage = [guideAttributes objectForKey:kPFGuideChangedImage];
    self.titleLabelAlternate.text = nil;       // clear this label in case a photo was just added
    
    if (changedImage || self.guide.image) {
        // display title in the navigation bar
        self.title = self.guide.title;
    }
 

    if (changedImage) {
        // there is a new picture in the cache
        self.guidePicture.image = changedImage;
        self.guidePicture.file = nil;
    }
    else if (self.guide.image) {
        // there is an existing picture in the object record
        self.guidePicture.file = self.guide.image;
        if (!self.guidePicture.image) {
            self.guidePicture.image = [UIImage imageNamed:@"image.png"];
        }
        [self.guidePicture loadInBackground];
    }
    else {
        // there is no photo so display title in that area of the screen
        self.titleLabelAlternate.text = self.guide.title;
        self.title = nil;
        self.guidePicture.image = nil;  // make sure an old image is removed
    }
    
    self.currentState = isReset;
    self.currentLine = [NSNumber numberWithInt:0];
    if (self.guide) {
        self.dialogController.guide = self.guide;
    }
    
    self.selectedRowNumber = -1;
    
    // Make sure prompt label is displayed
    [self.view bringSubviewToFront:self.statusDisplay];

    // Check microphone permissions
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                // enable the Play & Reset bar button items
                [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    UIBarButtonItem *button = obj;
                    button.enabled = YES;
                }];
            }
            else {
                // disable the Play & Reset button
                [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    UIBarButtonItem *button = obj;
                    if ( (button.tag == isPlaying) || (button.tag == isReset) ) {
                        button.enabled = NO;
                    }
                }];
                // Let the user know that they need to turn on the microphone in the system settings
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                                                message:@"Talk Lists uses the microphone for voice recognition.  To use this feature you must allow microphone access in Settings > Privacy > Microphone"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    
    // sign up for AVAudioSession Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioServicesReset:)
                                                 name:AVAudioSessionMediaServicesWereResetNotification
                                               object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:[AVAudioSession sharedInstance]];
    

}

-(void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    // NOTE:  To keep the Edit button from briefly displaying then disappearing, I would like the self.editButton to be disabled by default at this point in the execution but
    // I can't seem to get it to be that way dispite unchecking the Enabled button for it in the Storyboard.
    // I also tried explicitly setting it the disabled in awakeFromNib and initWithCoder but that didn't work either.
    
    // check to see if current user is the owner of this guide, if so enable Edit and the Action buttons
    PFACL *guideACL = self.guide.ACL;
    if ([guideACL getWriteAccessForUser:[PFUser currentUser]]) {
        // user is the owner of this guide
        self.editButton.enabled = YES;
        // check if guide is already shared and if so diable Action button
        if ([guideACL getPublicReadAccess] == YES)
        {
            self.actionButton.enabled = NO;
        }
        else {
            self.actionButton.enabled = YES;
        }
    }
    else {
        // user is NOT owner of this guide
        self.editButton.enabled = NO;
        self.actionButton.enabled = NO;
    }

}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.titleLabelAlternate.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabelAlternate.bounds);
    [super viewWillLayoutSubviews];
}


- (void)viewWillDisappear:(BOOL)animated
{
    // View is going away so pause the dialog
    if (self.currentState == isPlaying) {
        [self pauseButtonPressed:nil];
    }
    
    // release the listener object
    [self.dialogController killListeningController];
 
    // don't watch for audio notificiations anymore
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
}


#pragma mark GuideQueryTableViewControllerDelegate

-(void)rowSelectedAtIndex:(int)index
{
    self.selectedRowNumber = index;
    
    BOOL wasPlaying = NO;
    if (self.currentState == isPlaying) {
        [self pauseButtonPressed:nil];
        wasPlaying = YES;
    }
    self.dialogController.currentLineIndex = index;
    self.currentLine = [NSNumber numberWithInt:index];
    if (wasPlaying == YES) {
        [self playButtonPressed:nil];
    }
    
}


#pragma mark dialogControllerDelegate Methods

- (void)dialogComplete
{
    NSLog(@"DIALOG OVER");
    [self setPlayButton];
    
     // update state
    self.currentState = isReset;
    
}

- (void)dialogStartedListening
{
    self.statusDisplay.text =  self.stateStrings[0];
}

- (void)dialogStoppedListening
{
    self.statusDisplay.text = @"";
}

- (void)dialogDecodingSpeech
{
    self.statusDisplay.text = self.stateStrings[3];
}

- (void)dialogComprehendedSpeech
{
    
}

- (void)dialogFailedToComprehendSpeech
{
    self.statusDisplay.text = @"Say again ?";
}

-(void) setPlayButton
{
    [self.playPauseButton setImage:[UIImage imageNamed:@"play-green"] forState:UIControlStateNormal ];
    // change action
    [self.playPauseButton removeTarget:self
                                action:@selector(pauseButtonPressed:)
                      forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseButton addTarget:self
                             action:@selector(playButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
}

 -(void) setPauseButton
{
    [self.playPauseButton setImage:[UIImage imageNamed:@"pause-orange"] forState:UIControlStateNormal ];
    // change action
    [self.playPauseButton removeTarget:self
                                action:@selector(playButtonPressed:)
                      forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseButton addTarget:self
                             action:@selector(pauseButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)highlightCurrentLine:(int) lineNumber
{
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:lineNumber inSection:0];
   
    // get app's customTint color
    UIColor *customColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kHighlightColor]];
    [self setTextColor:customColor atIndexPath:selectedIndexPath];
 }

- (void)unhighlightCurrentLine:(int) lineNumber
{
     // Pass this through to child controller
    GuideQueryTableViewController *childController = (GuideQueryTableViewController *)[self.childViewControllers firstObject];
    if ([childController respondsToSelector:@selector(unhighlightCurrentLine:)]) {
        [childController unhighlightCurrentLine:lineNumber];
    }
}

-(void)setTextColor:(UIColor *)highlightColor atIndexPath:(NSIndexPath *)lineNumber
{

    // Pass this through to child controller
    GuideQueryTableViewController *childController = (GuideQueryTableViewController *)[self.childViewControllers firstObject];
    if ([childController respondsToSelector:@selector(setTextColor:atIndexPath:)]) {
        [childController setTextColor:highlightColor atIndexPath:lineNumber];
    }
}

#pragma mark EditGuideViewControllerDelegate

-(void) changedGuideUploading
{
    if ([self.editGuideDelegate respondsToSelector:@selector(changedGuideUploading)] ) {
        [self.editGuideDelegate changedGuideUploading];
    }
}

-(void) changedGuideFinishedUpload
{
    if ([self.editGuideDelegate respondsToSelector:@selector(changedGuideFinishedUpload)]) {
        [self.editGuideDelegate changedGuideFinishedUpload];
    }
}

-(void) changedStepUploading
{
    GuideQueryTableViewController *stepTableViewController = (GuideQueryTableViewController *)[self.childViewControllers firstObject];
    [stepTableViewController.tableView reloadData];
}

-(void) changedStepFinishedUpload
{
    GuideQueryTableViewController *stepTableViewController = (GuideQueryTableViewController *)[self.childViewControllers firstObject];
    [stepTableViewController loadObjects];
}


#pragma mark User Actions

- (IBAction)playButtonPressed:(UIButton *)sender {
    // toggle button to 'Pause'
    [self setPauseButton];
    
    // Start the dialog
    if (self.guide)
    {
        if (self.dialogController) {
            if (self.currentState == isReset) {
                self.currentLine = 0;
                [self.dialogController startDialog];
            }
            else if (self.currentState == isPaused) {
                [self.dialogController resumeDialog];
            }
            self.currentState = isPlaying;
        }
    }

}

- (IBAction)pauseButtonPressed:(UIButton *)sender
{
    // toggle the button  to 'Play'
    [self setPlayButton];
    
    // Pause the dialog
    if (self.dialogController) {
        [self.dialogController pauseDialog];
        self.currentState = isPaused;
    }
}

- (IBAction)resetButtonPressed:(UIButton *)sender
{
        // Make sure Play/Pause button is showing Play
        if (self.currentState == isPlaying) {
            [self pauseButtonPressed:self.playPauseButton];
        }
        
        // Stop the dialog
        if (self.dialogController) {
            [self.dialogController initializeDialog];
        }
        
        // release the listener object
     //   [self.dialogController killListeningController];
    
        self.currentState = isReset;

}

- (IBAction)actionButtonPressed:(UIBarButtonItem *)sende
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Publish Guide"
                                                        message:@"Share Guide With Everyone ?"
                                                       delegate:self
                                              cancelButtonTitle:@"No" otherButtonTitles:@"Share !",nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
 //   NSLog(@"clicked button index %ld",(long)buttonIndex);
    if (buttonIndex == 1) {
        // change the read permissions for this guide to PUBLIC
        [self.guide.ACL setPublicReadAccess:YES];
        [self.guide saveInBackground];
        // change the read permisions for all the guide steps to PUBLIC
        GuideQueryTableViewController *stepTableViewController = (GuideQueryTableViewController *)[self.childViewControllers firstObject];
        [stepTableViewController setStepAccessToPublic:YES];
    }
}

-(void) terminateActivity
{
    if (self.currentState == isPlaying) {
        [self pauseButtonPressed:self.playPauseButton];
        [self.dialogController stopAllAudio];
        
        // clear status display as it won't get done in the callback from the dialog controller since we're going into the background
        self.statusDisplay.text = @"";
        }
}



#pragma mark AVAudioSession Notifications

- (void)audioInterruption: (NSNotification *)notification
{
    NSUInteger type = [[[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"BEGAN INTERRUPTION, dialog state %d", (int)self.currentState);
        
        if (self.currentState == isPlaying) {
           //  [self terminateActivity];
            [self pauseButtonPressed:self.playPauseButton];
            
            // clear status display as it won't get done in the callback from the dialog controller since we're going into the background
            self.statusDisplay.text = @"";

        }
    }
    else if (type == AVAudioSessionInterruptionTypeEnded) {
        NSLog(@"END INTERRUPTION, dialog state %d", (int)self.currentState);
     }
}

-(void)audioServicesReset: (NSNotification *)notification
{
    NSLog(@"RECEIVED AUDIO SERVICES RESET NOTIFICATION");
  //  TalkListAppDelegate *myApp = [UIApplication sharedApplication].delegate;
    [self.dialogController killListeningController];
    
  //  [self.dialogController recoverFromAudioResetNotification];
}

-(void)audioRouteChange: (NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    AVAudioSessionRouteChangeReason changeReason = [[dict valueForKey: AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    AVAudioSessionRouteDescription *route = [dict valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
    NSLog(@"RECEIVED AUDIO SERVICES ROUTE CHANGE NOTIFICATION %d, %@", (int)changeReason,route);
    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        // pause dialog
        
    }
    else if (changeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        // put up alert for user to resume dialog or abort dialog
        
    }
    else if (changeReason == AVAudioSessionRouteChangeReasonCategoryChange) {
        // make sure audio category is set back to playAndRecord
        if (self.routeChangeInProcess == NO) {
            self.routeChangeInProcess = YES;
            self.originalAudioRoute = route;
        }
        if ( (self.routeChangeInProcess == YES) && (![route isEqual: self.originalAudioRoute]) ){
            [self.dialogController recoverFromAudioCategoryChange];
            
            self.routeChangeInProcess = NO;
        }

    }
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue isKindOfClass:[BlurryModalSegue class]])
    {
        BlurryModalSegue* bms = (BlurryModalSegue*)segue;
        
        bms.backingImageBlurRadius = @(20);
        bms.backingImageSaturationDeltaFactor = @(.45);
        bms.backingImageTintColor = [[UIColor greenColor] colorWithAlphaComponent:.1];
    }
    else if ([[segue destinationViewController  ]isKindOfClass:[EditGuideViewController class]])
    {
        EditGuideViewController *destController = (EditGuideViewController *)[segue destinationViewController];
        destController.guideToEdit = self.guide;
        destController.downloadedGuideImage = self.guidePicture.image;
        destController.stepNumber = self.selectedRowNumber+1;
        destController.editGuideDelegate = self;
    }
    else if ([segue.identifier isEqualToString:@"guideDetailTableViewSegue"]) {
        GuideQueryTableViewController *destinationVC = (GuideQueryTableViewController *)[segue destinationViewController];
        destinationVC.guide = self.guide;
        destinationVC.parentDelegate = self;
    }
}

#pragma mark initializers

- (NSArray *)stateStrings
{
    if (!_stateStrings) {
        _stateStrings =  @[@"Say \"Next\" or \"Repeat\"", @"Waiting to resume", @"Reset", @"Figuring out what you said"];
    }
    return _stateStrings;
}

- (void)setCurrentLine:(NSNumber *)currentLine
{
    if ([_currentLine integerValue] >= 0) {
        [self unhighlightCurrentLine:(int)[_currentLine integerValue]];
    }

    _currentLine = currentLine;
    
    if ([currentLine integerValue] >= 0) {
        [self highlightCurrentLine:(int)[currentLine integerValue]];
    }
}

@end
