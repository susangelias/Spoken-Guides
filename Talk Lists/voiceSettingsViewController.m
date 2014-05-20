//
//  voiceSettingsVCViewController.m
//  textToSpeech
//
//  Created by Susan Elias on 3/2/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "voiceSettingsViewController.h"
#import "Voice.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


@interface voiceSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;
@property (strong, nonatomic) Voice *myVoice;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *MPVolumeViewParentView;

@end


@implementation voiceSettingsViewController

#pragma mark Initializations

- (Voice *)myVoice
{
    if (!_myVoice) {
        _myVoice = [Voice sharedInstance];
    }
    return _myVoice;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // set the min/max values for the rate slider
    self.rateSlider.minimumValue = AVSpeechUtteranceMinimumSpeechRate;
    self.rateSlider.maximumValue = MAX_RATE_SLIDER;
    
    // load current settings from the model
    self.rateSlider.value = [self.myVoice.rate floatValue];
    self.pitchSlider.value = [self.myVoice.pitch floatValue];
    
    // setup the system volume slider
    // NOTE:  ONLY DISPLAYS ON DEVICE, NOT ON SIMULATOR
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame:self.MPVolumeViewParentView.bounds];
    [self.MPVolumeViewParentView addSubview:myVolumeView];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    
    // make sure background is not translusent when it slides on screen
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"OffWhite"]];
    
    // set the tint color for the Cancel and Done buttons
 //   self.cancelButton.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Charcoal"]];
 //   self.doneButton.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Charcoal"]];
    
}
#pragma mark Actions

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    // don't save any of the slider settings into the voice shared instance
    // just dismiss modal view controller
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:NULL];
}

- (IBAction)DoneButtonPressed:(UIButton *)sender {
  
    // save slider settings to the voice shared instance
    self.myVoice.pitch = [NSNumber numberWithFloat:self.pitchSlider.value];
    self.myVoice.rate  = [NSNumber numberWithFloat:self.rateSlider.value];
//    self.myVoice.volume = [NSNumber numberWithFloat:self.volumeSlider.value];

    // dismiss modal view controller
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:NULL];
}



@end
