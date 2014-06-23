//
//  GuideDetailViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideDetailViewController.h"
#import "BlurryModalSegue.h"
#import "stepCell.h"
#import "Step.h"
//#import "fetchedResultsDataSource.h"
//#import "fetchedResultsDataSourceDelegate.h"
#import "parseDataSource.h"
#import "parseDataSourceDelegate.h"
#import "Guide+Addendums.h"
#import "dialogController.h"
#import "Photo+Addendums.h"
#import "TalkListAppDelegate.h"
#import "EditGuideViewController.h"
#import "ShareController.h"
#import "PFStep.h"


typedef NS_ENUM(NSInteger, dialogState) {
    isPlaying,
    isPaused,
    isReset
};

@interface GuideDetailViewController () <parseDataSourceDelegate, UITableViewDelegate, dialogControllerDelegate >
// View properties
@property (weak, nonatomic) IBOutlet UITableView *guideTableView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIImageView *guidePicture;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *statusDisplay;
@property (nonatomic, strong) NSArray *stateStrings;

// Model properties
//@property (strong, nonatomic) fetchedResultsDataSource *guideDetailVCDataSource;

@property (strong, nonatomic) parseDataSource *guideDetailVCDataSource;

@property (strong, nonatomic) dialogController  *dialogController;
@property dialogState currentState;

@end

@implementation GuideDetailViewController

#pragma mark View lifecycle

- (void)awakeFromNib
{
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

    self.guideTableView.dataSource = self.guideDetailVCDataSource;
    self.guideTableView.delegate = self;

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
  /*
    // add the share button to the nav toolbar
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                               target:self
                                                                                               action:@selector(shareButtonPressed:)];
    NSMutableArray *mutableBarButtonItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    [mutableBarButtonItems addObject:shareButton];
    self.navigationItem.rightBarButtonItems = [mutableBarButtonItems copy];
   */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self.guideDetailVCDataSource refreshQuery];
  //  [self.guideTableView reloadData];
    
    self.title = self.guide.title;
   // self.guidePicture.image = [UIImage imageWithData:self.guide.photo.thumbnail];
 //   [self.guideTableView reloadData];
    
    self.currentState = isReset;
    self.currentLine = 0;
    if (self.guide) {
        self.dialogController.guide = self.guide;
    }
    
    
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


- (void)viewWillDisappear:(BOOL)animated
{
    // View is going away so pause the dialog
    if (self.currentState == isPlaying) {
        [self pauseButtonPressed:nil];
    }
    
    // Remove self as observer for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
}

#pragma mark - parseDataSourceDelegate methods

-(void)queryComplete
{
    self.guide.stepsInGuide = [self.guideDetailVCDataSource.queryResults copy];
    [self.guideTableView reloadData];
}

-(void)deletedRowAtIndex:(NSUInteger)index
{
  //  [self.guideTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)movedRowFrom:(NSUInteger)fromIndex To:(NSUInteger) toIndex
{
    [self.guide moveStepFromNumber:fromIndex+1 toNumber:toIndex+1];
    
    // turn off editing mode automatically after a row is moved
    [self.guideTableView setEditing:NO animated:YES];
    
    // erase the dialog controller's list of steps and let it rebuild them
    self.dialogController.instructions = nil;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL wasPlaying = NO;
    if (self.currentState == isPlaying) {
        [self pauseButtonPressed:nil];
        wasPlaying = YES;
    }
    self.dialogController.currentLineIndex = (int)indexPath.row;
    self.currentLine = [NSNumber numberWithInt:indexPath.row];
    if (wasPlaying == YES) {
        [self playButtonPressed:nil];
    }
    
    // unselect the row since text color will change when row is spoken
    UITableViewCell *selectedCell = [self.guideTableView cellForRowAtIndexPath:indexPath];
    [selectedCell setSelected:NO animated:YES ];
}


#pragma mark dialogControllerDelegate Methods

- (void)dialogComplete
{
    NSLog(@"DIALOG OVER");
    // Set the Pause button back to Play
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIBarButtonItem *button = obj;
        if (button.tag == isPaused) {
            [self swapPlayPauseButtons];
        }
    }];
    
    // Enable the Edit Button
 //   self.navigationItem.rightBarButtonItem.enabled = YES;
    
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
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:lineNumber inSection:0];
    
    // get app's customTint color
    UIColor *customColor = [UIColor blackColor];
    [self setTextColor:customColor atIndexPath:selectedIndexPath];
}

-(void)setTextColor:(UIColor *)highlightColor atIndexPath:(NSIndexPath *)lineNumber
{
    UITableViewCell *currentCell = [self.guideTableView cellForRowAtIndexPath:lineNumber];
    NSMutableAttributedString *cellAttributedText = [currentCell.textLabel.attributedText mutableCopy];
    NSDictionary *highlightedTextAttributes;
    NSRange highlightedRange;
    if (lineNumber >= 0)  {
        // HIGHLIGHT STROKE COLOR OF CURRENT LINE
        if (highlightColor) {
            highlightedTextAttributes  = @{NSForegroundColorAttributeName: highlightColor};
            highlightedRange =  NSMakeRange(0, [cellAttributedText length]);
        }
    }
    // APPLY ATTRIBUTES
    if (highlightedTextAttributes) {
        [cellAttributedText addAttributes:highlightedTextAttributes range:highlightedRange];
    }
    currentCell.textLabel.attributedText = [cellAttributedText copy];
    
}


#pragma mark User Actions

- (IBAction)playButtonPressed:(UIButton *)sender {
    // toggle button to 'Pause'
    [self swapPlayPauseButtons];
    
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
    [self swapPlayPauseButtons];
    
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

- (IBAction)longPressGestureRecognized:(id)sender
{
    
    self.guideDetailVCDataSource.rearrangingAllowed = YES;
  //  self.guideStepsDataSource.editingAllowed = YES;
    [self.guideTableView setEditing:YES
                          animated:YES];
}

- (IBAction)shareButtonPressed:(UIBarButtonItem *)sender
{
    ShareController *shareControl = [[ShareController alloc]init];
    [shareControl shareGuide:self.guide];
}

#pragma mark AVAudioSession Notifications

- (void)audioInterruption: (NSNotification *)notification
{
    NSUInteger type = [[[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"BEGAN INTERRUPTION, dialog state %d", (int)self.currentState);
        if (self.currentState == isPlaying) {
            [self pauseButtonPressed:self.playPauseButton];
            // release the listener object
            TalkListAppDelegate *myApp = [UIApplication sharedApplication].delegate;
            [myApp killListeningController];
        }
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
 //       destController.managedObjectContext = self.guide.managedObjectContext;
        destController.guideToEdit = self.guide;
        destController.steps = [self.guideDetailVCDataSource.queryResults mutableCopy];
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

/*
-(ArrayDataSource *)guideDetailVCDataSource
{
    if (!_guideDetailVCDataSource) {
        // set up the block that will fill each tableViewCell
        void (^configureCell)(stepCell *, id) = ^(stepCell *cell, Step *guideStep) {
            [cell configureStepCell:guideStep];
        };
        
        // get the guide steps from our working copy of the new guide in progress
        NSMutableArray *guideSteps = [[self.guide sortedSteps] mutableCopy];
  
        _guideDetailVCDataSource = [[ArrayDataSource alloc] initWithItems:guideSteps
                                                          cellIDString:@"stepCell"
                                                    configureCellBlock:configureCell];
        _guideDetailVCDataSource.arrayDataSourceDelegate = self;
        
         
    }
    return _guideDetailVCDataSource;
}
*/

/*
-(fetchedResultsDataSource *)guideDetailVCDataSource
{
    if (!_guideDetailVCDataSource) {
        void (^configureCell)(UITableViewCell *, id) = ^(UITableViewCell *cell, Step *guideStep) {
            if ([cell isKindOfClass:[stepCell class]]) {
                stepCell *thisStepCell = (stepCell *)cell;
                [thisStepCell configureStepCell:guideStep];
            }
        };
            
     //   NSString *searchString = self.guide;
       // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"belongsToGuide == %@", searchString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"belongsToGuide == %@", self.guide];
 
        _guideDetailVCDataSource = [[fetchedResultsDataSource alloc] initWithEntity:@"Step"
                                                               withManagedObjectContext:self.guide.managedObjectContext
                                                                            withSortKey:@"rank"
                                                                    withCellIndentifier:@"stepCell"
                                                                    withSearchPredicate:predicate
                                                                     withConfigureBlock:configureCell];
    }
    _guideDetailVCDataSource.delegate = self;
    _guideDetailVCDataSource.fetchedResultsDataSourceDelegate = self;
    return _guideDetailVCDataSource;
}
*/

-(parseDataSource *)guideDetailVCDataSource
{
    if (!_guideDetailVCDataSource) {
        void (^configureCell)(UITableViewCell *, id) = ^(UITableViewCell *cell, PFStep *guideStep) {
            if ([cell isKindOfClass:[stepCell class]]) {
                stepCell *thisStepCell = (stepCell *)cell;
                [thisStepCell configureStepCell:guideStep];
            }
        };
        

        _guideDetailVCDataSource = [[parseDataSource alloc] initWithPFObjectClassName:@"PFStep"
                                                                          withSortKey:@"rank"
                                                                         withMatchKey:@"belongsToGuide"
                                                                      WithMatchString:self.guide.objectId
                                                                  withCellIndentifier:@"stepCell"
                                                                   configureCellBlock:configureCell];
        _guideDetailVCDataSource.parseDataSourceDelegate = self;
    }
    return _guideDetailVCDataSource;
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
