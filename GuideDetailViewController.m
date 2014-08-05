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

@interface GuideDetailViewController () < dialogControllerDelegate, UITableViewDelegate, GuideQueryTableViewControllerDelegate, EditGuideViewControllerDelegate>

// View properties
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet PFImageView *guidePicture;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *statusDisplay;
@property (nonatomic, strong) NSArray *stateStrings;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelAlternate;

@property (strong, nonatomic) dialogController  *dialogController;
@property dialogState currentState;

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
    
    // sign up for system notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];

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
    self.currentLine = 0;
    if (self.guide) {
        self.dialogController.guide = self.guide;
    }
    
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
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    // check to see if current user is the owner of this guide, if so enable Edit button
    PFACL *guideACL = self.guide.ACL;
    if ([guideACL getWriteAccessForUser:[PFUser currentUser]]) {
        self.editButton.enabled = YES;
        //   self.editButtonItem.enabled = YES;
    }
    else {
        //  self.editButtonItem.enabled = NO;
        self.editButton.enabled = NO;
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    // View is going away so pause the dialog
    if (self.currentState == isPlaying) {
        [self pauseButtonPressed:nil];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark GuideQueryTableViewControllerDelegate

-(void)rowSelectedAtIndex:(int)index
{
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

/*
- (void)swapPlayPauseButtons
{
    
    UIImage *playPauseImage = [self.playPauseButton imageForState:UIControlStateNormal];
    if (playPauseImage == [UIImage imageNamed:@"play"]) {
        // replace Play button with Pause button
        [self.playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal ];
        // change action
        [self.playPauseButton removeTarget:self
                               action:@selector(playButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self.playPauseButton addTarget:self
                            action:@selector(pauseButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        // replace Pause button with Play button
        [self.playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal ];
        // change action
        [self.playPauseButton removeTarget:self
                               action:@selector(pauseButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self.playPauseButton addTarget:self
                            action:@selector(playButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
     
}
 */

-(void) setPlayButton
{
    [self.playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal ];
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
    [self.playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal ];
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
  //  UIColor *customColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Tangarine"]];
    UIColor *customColor = [UIColor blueColor];
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
    [self.editGuideDelegate changedGuideUploading];
}

-(void) changedGuideFinishedUpload
{
    [self.editGuideDelegate changedGuideFinishedUpload];
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
  //  [self swapPlayPauseButtons];
    [self setPauseButton];
    
    // Disable the Edit button
 //   self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Start the dialog
    if (self.guide)
    {
        if (self.dialogController) {
            if (self.currentState == isReset) {
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
        
        // Enable the Edit button
    //    self.navigationItem.rightBarButtonItem.enabled = YES;
    
        self.currentState = isReset;

}

-(void) terminateActivity
{
    if (self.currentState == isPlaying) {
        [self pauseButtonPressed:self.playPauseButton];
        [self.dialogController stopAllAudio];
        
        // clear status display as it won't get done in the callback from the dialog controller since we're going into the background
        self.statusDisplay.text = @"";
        
        // release the listener object
        TalkListAppDelegate *myApp = [UIApplication sharedApplication].delegate;
        [myApp killListeningController];
    }
}

#pragma mark UIApplication Notifications

-(void)resignActive: (NSNotification *)notification
{
    NSLog(@"did receive resign Active");
    [self terminateActivity];
}

#pragma mark AVAudioSession Notifications

- (void)audioInterruption: (NSNotification *)notification
{
    NSUInteger type = [[[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"BEGAN INTERRUPTION, dialog state %d", (int)self.currentState);
        /*
        if (self.currentState == isPlaying) {
            [self pauseButtonPressed:self.playPauseButton];
            // release the listener object
            TalkListAppDelegate *myApp = [UIApplication sharedApplication].delegate;
            [myApp killListeningController];
        } */
        [self terminateActivity];
    }
    else if (type == AVAudioSessionInterruptionTypeEnded) {
        NSLog(@"END INTERRUPTION, dialog state %d", (int)self.currentState);
        //   if (self.currentState == isPaused) {
        //       [self playButtonPressed:self.playButton];
        //  }
    }
}

-(void)audioServicesReset: (NSNotification *)notification
{
    NSLog(@"RECEIVED AUDIO SERVICES RESET NOTIFICATION");
    TalkListAppDelegate *myApp = [UIApplication sharedApplication].delegate;
    [myApp killListeningController];
    
    [self.dialogController recoverFromAudioResetNotification];
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
        _stateStrings =  @[@"Say \"Next\" or \"Repeat\"", @"Waiting to resume", @"Reset"];
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
