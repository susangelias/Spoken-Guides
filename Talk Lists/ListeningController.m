//
//  AudioInputViewController.m
//  AudioInput
//
//  Created by Susan Elias on 3/10/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "ListeningController.h"
#import <OpenEars/PocketsphinxController.h>
#import "languageOpenEars.h"
#import <OpenEars/OpenEarsLogging.h>


@interface ListeningController ()


@property (nonatomic, strong) PocketsphinxController *pocketsphinxController;
@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) languageOpenEars *languageModel;
@property (nonatomic, strong) LanguageModelGenerator *lmGenerator;
@property BOOL ignoreHeardSpeech;
@property BOOL calibrationJustHappened;
@property (nonatomic, strong) NSDate *start;        // for debugging

@end

@implementation ListeningController

#define kPOCKET_SPHINX_CALIBRATION_LEVEL 1
#define kPHRASE_LENGTH_LIMIT 10


-(ListeningController *)init
{

    self = [super init];

    if (!self) return nil;
    
    [self.openEarsEventsObserver setDelegate:self];
                      
    [self.pocketsphinxController setCalibrationTime:kPOCKET_SPHINX_CALIBRATION_LEVEL];
    self.pocketsphinxController.returnNullHypotheses = YES;
    self.isCalibrated = NO;
                      
    self.languageModel = [[languageOpenEars alloc]init];
    self.lmGenerator = self.languageModel.lmGenerator;      // This object takes a couple of seconds to generate
   
    [OpenEarsLogging startOpenEarsLogging];
    return self;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (_openEarsEventsObserver == nil) {
		_openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return _openEarsEventsObserver;
}

- (PocketsphinxController *)pocketsphinxController {
	if (_pocketsphinxController == nil) {
		_pocketsphinxController = [[PocketsphinxController alloc] init];
        _pocketsphinxController.audioSessionMixing = TRUE;   // ALLOW AUDIO INTERUPTIONS
	}
	return _pocketsphinxController;
}



- (void) startListening
{
    self.start = [NSDate date];
    if (self.lmGenerator) {
        if ([self.pocketsphinxController isSuspended]) {
            [self.pocketsphinxController resumeRecognition];
        }
        else {
            [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.languageModel.lmPath
                                                          dictionaryAtPath:self.languageModel.dicPath
                                                       acousticModelAtPath:self.languageModel.acousticModelPath languageModelIsJSGF:NO];
        }
    }
    self.ignoreHeardSpeech = NO;
}

- (void) stopListening
{
    if ([self.pocketsphinxController isListening] || [self.pocketsphinxController isSuspended]) {
        [self.pocketsphinxController stopListening];
    }
}

- (BOOL) isListening
{
    return [self.pocketsphinxController isListening];
}

- (void) suspendListening
{
    [self.pocketsphinxController suspendRecognition];
}

- (BOOL) isSuspended
{
    return [self.pocketsphinxController isSuspended];
}

- (void) resumeListening
{
    [self.pocketsphinxController resumeRecognition];
}

#pragma mark OpenEarsEventsObserver Delgate Methods

- (commandType)proceed:(NSString *)hypothesis
{
    __block commandType command = PROCEED;

    NSArray *repeatCommands = [self.languageModel.commands valueForKey:gREPEAT_COMMAND_KEY];
    [repeatCommands enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *repeatCommand = obj;
        if ([hypothesis isEqualToString:repeatCommand]) {
            command = REPEAT;
        }
    }];
    NSArray *goBackCommands = [self.languageModel.commands valueForKey:gGO_BACK_COMMAND_KEY];
    [goBackCommands enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *goBackCommand = obj;
        if ([hypothesis isEqualToString:goBackCommand]) {
            command = GO_BACK;
        }
    }];
    return command;

}

- (BOOL)heardSpeechMatchesOneOfOurCommandPhrases:(NSString *)hypothesis
{
    __block BOOL result = NO;
    
    NSArray *commandPhrases = [self.languageModel.commands allValues];
    
    [commandPhrases enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *commandStrings = obj;
        [commandStrings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *command = obj;
            if ([hypothesis isEqualToString:command]) {
                result = YES;
        }
        }];
    }];
    return result;
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
  /*
    // debugging to ipad textView
    NSString *baseText = @"The received hypothesis is ";
    NSMutableString *heardText = [[baseText stringByAppendingString:hypothesis]mutableCopy];
    heardText = [[heardText stringByAppendingString:@" with a score of "]mutableCopy];
    heardText = [[heardText stringByAppendingString:recognitionScore]mutableCopy];
    */
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    if ([hypothesis length] <= kPHRASE_LENGTH_LIMIT) {
        if ([self heardSpeechMatchesOneOfOurCommandPhrases:hypothesis]) {
            // Let the dialogController know that speech has occured
            if (self.delegate && [self.delegate respondsToSelector:@selector(userHasSpoken:)]) {
                [self.delegate userHasSpoken:[self proceed:hypothesis]];
            }
        }
        else {
            // didn't understand what the user said
            if ([self.delegate respondsToSelector:@selector(userHasSpoken:)]) {
                [self.delegate userHasSpoken:-1];
            }
        }
    }
}


- (void) pocketsphinxDidStartCalibration {

	NSLog(@"Pocketsphinx calibration has started. %@", self.start);
}

- (void) pocketsphinxDidCompleteCalibration {
    /*
    if ([self isListening]) {
        [self suspendListening];
    }
    else {
        NSAssert(YES, @"listener = %@", self);
    }
     */
    self.calibrationJustHappened = YES;
    self.isCalibrated = YES;
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.  %f", [self.start timeIntervalSinceNow]);
    if ([self.delegate respondsToSelector:@selector(startedListening)]) {
        [self.delegate startedListening];
    }
    if (self.calibrationJustHappened == YES) {
        self.calibrationJustHappened = NO;
    }
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
    if ([self.delegate respondsToSelector:@selector(detectedSpeech)]) {
        [self.delegate detectedSpeech];
    }
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
    if ([self.delegate respondsToSelector:@selector(stoppedListening)]) {
        [self.delegate stoppedListening];
    }
}

- (void) pocketsphinxDidSuspendRecognition {
    if ([self.delegate respondsToSelector:@selector(stoppedListening)]) {
        [self.delegate stoppedListening];
    }	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    if ([self.delegate respondsToSelector:@selector(startedListening)]) {
        [self.delegate startedListening];
    }
	NSLog(@"Pocketsphinx has resumed recognition.");
}


- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
    // try again
    self.pocketsphinxController = nil;
    [self pocketsphinxController];
}
- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}

@end


