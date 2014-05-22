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
#import "Step+Addendums.h"

typedef NS_ENUM(NSInteger, dialogControllerState) {
    isPausedWhileSpeaking,
    isPausedWhileListening,
    isActivelySpeaking,
    isActivelyListening,
    isInactive
};

@interface dialogController()

@property (nonatomic, strong) SpeakingController *speaker;
@property (nonatomic, weak) ListeningController *listener;
@property (nonatomic, strong) NSString *nextLine;
@property (nonatomic, strong) NSString *heardText;  // for debuggin on iPad only
@property dialogControllerState currentState;
@property (nonatomic, strong) NSArray *instructions;

@end

@implementation dialogController

-(void)setGuide:(Guide *)guide
{
    _guide = guide;
    
    [self setupListener];
        
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

-(NSArray *)instructions
{
    if (!_instructions) {
        if (self.guide) {
            __block NSMutableArray *mutableInstructions = [[NSMutableArray alloc] init];
            [[self.guide sortedSteps] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (obj) {
                    Step *step = (Step *)obj;
                    if (step.instruction) {
                        [mutableInstructions addObject:step.instruction];
                    }
                }
                else {
                    *stop = YES;     // object should never be nil but if it is abort enumeration
                }
            }];
            _instructions = [mutableInstructions copy];
        }
        else {
            NSLog(@"Error:  no guide set %s", __PRETTY_FUNCTION__);
        }
    }
    return _instructions;
}

-(ListeningController *)listener
{
    // ListeningController is a singleton instantiated by the appDelegate
    TalkListAppDelegate *myApp = [UIApplication sharedApplication].delegate;
    _listener = myApp.listener;
    if (_listener) {
        // set ourself as the listener's delegate
        _listener.delegate = self;
    }
    return _listener;
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
    if (self.instructions) {
        self.nextLine = [self.instructions objectAtIndex:self.currentLineIndex];
    }
    // Let the Guide Detail VC know the current line so that it can highlight it
    [self.dialogControlDelegate setCurrentLine:[NSNumber numberWithInt:self.currentLineIndex]];
    if (self.nextLine) {
        NSString *verifiedLine = [languageOpenEars makePronounciationCorrections:self.nextLine];
        if ([self.listener isListening]) {
            [self.listener suspendListening];
        }
        [self.speaker speak:verifiedLine];
    }
    else {
        NSLog(@"Error next line %@", self.nextLine);
    }
}



- (void)startDialog
{
    if (self.currentLineIndex < [self.guide.stepInGuide count])     {
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
    if ([self.listener isListening]) {
        [self.listener suspendListening];
    }

}

- (void) initializeDialog {
    self.currentLineIndex = 0;
    [self.dialogControlDelegate setCurrentLine:[NSNumber numberWithInt:self.currentLineIndex]];
    [self suspendAllAudio];
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
        if (self.currentLineIndex < [self.guide.stepInGuide count])   {
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

-(void)recoverFromAudioResetNotification
{
    self.listener = nil;
    [self setupListener];
}

#pragma mark AudioInputDelegate Methods

- (void)userHasSpoken:(commandType)command
{

    if (self.currentState != isInactive) {
        if (command == PROCEED) {
            // SPEAK THE NEXT LINE
            self.currentLineIndex++;
            if (self.currentLineIndex < [self.guide.stepInGuide count])     {
                [self speakLine];
            }
            // ALREADY SPOKE LAST LINE OF INSTRUCTIONS - LET THE USER KNOW THIS
            else if (self.currentLineIndex == [self.guide.stepInGuide count]) {
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
    }
}

/*
- (void)userHasSpoken:(BOOL)proceed withText:(NSString *)heardText
{
    if (self.currentState != isInactive) {
        [self continueDialog];
    }
    // log debugging info
    if (heardText) {
        [self.delegate dialogHeardText:heardText];
    }
}
 */

- (void) heardTextIgnored:(NSString *)ignoredText // method for printing debugging info on iPad
{
    if (ignoredText) {
        [self.dialogControlDelegate dialogHeardText:ignoredText];
    }
}

-(void)startedListening
{
    [self.dialogControlDelegate dialogStartedListening];
}

-(void)stoppedListening
{
    [self.dialogControlDelegate dialogStoppedListening];
}

-(void)calibrationComplete
{
    if ( (!self.currentState == isActivelyListening ) && ([self.listener isListening]) ) {
        [self.listener suspendListening];
    }
}

#pragma mark textSpeechControllerDelegate Methods

- (void)appHasFinishedSpeaking
{
    if ( (self.currentLineIndex < [self.guide.stepInGuide count]) && (self.currentState == isActivelySpeaking) ) {
        // listen for next command from user
        if ([self.listener isSuspended]) {
            [self.listener resumeListening];
        }
        self.currentState = isActivelyListening;
    }

    else if (self.currentState == isInactive) {
        [self.dialogControlDelegate dialogComplete];
        [self initializeDialog];        // set up to start dialog over if user presses Play again
    }

}

@end
