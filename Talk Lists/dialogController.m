//
//  dialogController.m
//  speech
//
//  Created by Susan Elias on 3/9/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "dialogController.h"
#import "languageOpenEars.h"
#import "voice.h"
#import "TalkListAppDelegate.h"
#import "PFStep.h"

typedef NS_ENUM(NSInteger, dialogControllerState) {
    isPausedWhileSpeaking,
    isPausedWhileListening,
    isActivelySpeaking,
    isActivelyListening,
    isInactive
};

@interface dialogController()

@property (nonatomic, strong) SpeakingController *speaker;
@property (nonatomic, strong) ListeningController *listener;
@property (nonatomic, strong) NSString *nextLine;
@property (nonatomic, strong) NSString *heardText;  // for debuggin on iPad only
@property dialogControllerState currentState;


@end

@implementation dialogController

-(void)setGuide:(PFGuide *)guide
{
    _guide = guide;
        
    // Instantiate speech controller
    if (!self.speaker) {
        self.speaker = [[SpeakingController alloc]init];
        if (self.speaker) {
            // set ourself as the speaker's delegate
            self.speaker.delegate = self;
        }
    }
    [self initializeDialog];
}

#pragma mark Listening Controller

// Need to allocate and initialize listener here because it takes several seconds, otherwise user
// could see delay in reponse after 1st line read
-(ListeningController *)createListeningController
{
    if (!_listener) {
        // Check microphone permissions
        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (!granted) {
                    // Let the user know that they need to turn on the microphone in the system settings
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                                                    message:@"Talk Notes uses the microphone for voice recognition.  To use this feature you must allow microphone access in Settings > Privacy > Microphone"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        
        _listener = [[ListeningController alloc] init];
        if (_listener) {
            [_listener startListening];  // start the calibration
            _listener.delegate = self;
        }
        
    }
    return _listener;
}


- (void)killListeningController
{
    if (self.listener) {
        if ([self.listener isListening]) {
            [self.listener stopListening];
        }
        self.listener = nil;
    }
}

-(void)setupListener
{
    if (![self.listener isListening]) {
        [self.listener startListening];
    }
}


#pragma mark Dialog Control Methods

- (void)speakLine
{
    self.currentState = isActivelySpeaking;
    
    // Speak a line
    if (self.guide.rankedStepsInGuide) {
        PFStep *step = [self.guide.rankedStepsInGuide objectAtIndex:self.currentLineIndex];
        self.nextLine = step.instruction;
    }
    // Let the Guide Detail VC know the current line so that it can highlight it
    if ([self.dialogControlDelegate respondsToSelector:@selector(setCurrentLine:)]) {
        [self.dialogControlDelegate setCurrentLine:[NSNumber numberWithInt:self.currentLineIndex]];
    }
    if (self.nextLine) {
        NSString *verifiedLine = [languageOpenEars makePronounciationCorrections:self.nextLine];
        [self.speaker speak:verifiedLine];
    }
    else {
        NSLog(@"Error next line %@", self.nextLine);
    }
}



- (void)startDialog
{

    if (!self.listener) {
        // create the listening controller and leave it in the listening state
        __weak typeof(self) weakSelf = self;
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf createListeningController];
        });
    }
    else {
        // reactivate the existing listening controller
        [self.listener startListening];
    }


    if (self.currentLineIndex < [self.guide.rankedStepsInGuide count])     {
        [self speakLine];
     }
    else {
        self.currentState = isInactive;
    }
}

-(void)stopAllAudio
{
    if ([self.speaker isSpeaking]) {
        [self.speaker stopSpeech];
     }
    if ([self.listener isListening]) {
        [self.listener stopListening];
    }
}

- (void)suspendAllAudio
{
    if ([self.speaker isSpeaking]) {
        [self.speaker stopSpeech];
    }
    if ([self.listener isListening] && ![self.listener isSuspended]) {
        [self.listener suspendListening];
    }

}

- (void) initializeDialog {
    self.currentLineIndex = 0;
    if ([self.dialogControlDelegate respondsToSelector:@selector(setCurrentLine:)]) {
        [self.dialogControlDelegate setCurrentLine:[NSNumber numberWithInt:self.currentLineIndex]];
    }
    self.currentState = isInactive;
}

- (void)pauseDialog {
    if ([self.speaker isSpeaking]) {
        self.currentState = isPausedWhileSpeaking;
    }
    else  { //if ( ([self.listener isListening]) && (![self.listener isSuspended]) ) {
        self.currentState = isPausedWhileListening;
    }

    [self suspendAllAudio];
}

-(void)resumeDialog {
    if (self.currentState == isPausedWhileSpeaking) {
        // REPEAT THE INTERUPTED LINE
        if (self.currentLineIndex < [self.guide.rankedStepsInGuide count])   {
            [self userHasSpoken:REPEAT];
        }
    } else if (self.currentState == isPausedWhileListening ) {
        // TELL USER THAT WE'RE WAITING FOR A RESPONSE
      //  [self.speaker speak:@"Resuming instructions, please say Next if you're ready for the next line, or, Repeat, if you want to hear the previous line."];
        // repeat the current line but let user know
      //  [self.speaker speak:@"Resuming dialog"];
        [self userHasSpoken:REPEAT];
    }
    self.currentState = isActivelySpeaking;
}

/*
-(void)recoverFromAudioResetNotification
{
    self.listener = nil;
    [self setupListener];
}
 */

- (void)recoverFromAudioCategoryChange
{
    [self killListeningController];
    
    [self createListeningController];
    
}

#pragma mark AudioInputDelegate Methods

- (void)userHasSpoken:(commandType)command
{
    // dismiss the processing label by assuming we understood the speech
    [self.dialogControlDelegate dialogComprehendedSpeech];
    
    if (self.currentState != isInactive) {
        if (command == PROCEED) {
            // SPEAK THE NEXT LINE
            self.currentLineIndex++;
            if (self.currentLineIndex < [self.guide.rankedStepsInGuide count])     {
                [self speakLine];
            }
            // ALREADY SPOKE LAST LINE OF INSTRUCTIONS - LET THE USER KNOW THIS
            else if (self.currentLineIndex == [self.guide.rankedStepsInGuide count]) {
                [self.speaker speak:@"End of instructions"];
                self.currentLineIndex++;
                self.currentState = isInactive;
            }
        }
        else if (command == REPEAT) {
            // REPEAT THE CURRENT LINE
            [self speakLine];
        }
        else if (command == GO_BACK) {
            // BACK UP 1 LINE
            if (self.currentLineIndex > 0) {
                self.currentLineIndex--;
            }
            [self speakLine];
        }
        else {
            // failed to recognize speech - let the user know
            [self.dialogControlDelegate dialogFailedToComprehendSpeech];
        }
    }
}


- (void) heardTextIgnored:(NSString *)ignoredText // method for printing debugging info on iPad
{
    if (ignoredText) {
        if ([self.dialogControlDelegate respondsToSelector:@selector(dialogHeardText:)]) {
            [self.dialogControlDelegate dialogHeardText:ignoredText];
        }
    }
}

-(void)startedListening
{
    NSLog(@"started listening in currentState %d", self.currentState);
    if (self.currentState == isActivelyListening) {
        if ([self.dialogControlDelegate respondsToSelector:@selector(dialogStartedListening)]) {
            [self.dialogControlDelegate dialogStartedListening];
        }
    }
    else {
        // suspend listening in all other states
        [self.listener suspendListening];
    }
}

-(void)stoppedListening
{
    if ([self.dialogControlDelegate respondsToSelector:@selector(dialogStoppedListening)]) {
        [self.dialogControlDelegate dialogStoppedListening];
    }
}

- (void) detectedSpeech
{
    [self.dialogControlDelegate dialogDecodingSpeech];
}



#pragma mark textSpeechControllerDelegate Methods

- (void)appHasFinishedSpeaking
{
    if ( (self.currentLineIndex < [self.guide.rankedStepsInGuide count]) && (self.currentState == isActivelySpeaking) ) {
        // listen for next command from user
        if ([self.listener isSuspended]) {
            [self.listener resumeListening];
        }
        self.currentState = isActivelyListening;
    }

    else if (self.currentState == isInactive) {
        if ([self.dialogControlDelegate respondsToSelector:@selector(dialogComplete)]) {
            [self.dialogControlDelegate dialogComplete];
        }
        if (self.listener) {
            [self.listener stopListening];
        }
        [self initializeDialog];        // set up to start dialog over if user presses Play again
    }

}

@end
