//
//  textSpeechController.m
//  speech
//
//  Created by Susan Elias on 3/9/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "SpeakingController.h"
#import "voice.h"


@interface SpeakingController()

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@property (nonatomic, strong) AVSpeechSynthesisVoice *synthesisVoice;
@property BOOL cancelled;
@end

@implementation SpeakingController

#pragma mark Initializations

- (AVSpeechSynthesisVoice *)synthesisVoice
{
    if (!_synthesisVoice)
    {
        NSString *preferredLanguage = [AVSpeechSynthesisVoice currentLanguageCode];
        _synthesisVoice = [AVSpeechSynthesisVoice voiceWithLanguage:preferredLanguage];
        
        self.cancelled = NO;
    }
    return _synthesisVoice;
}

- (AVSpeechSynthesizer *)synthesizer
{
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
   _synthesizer.delegate = self;
    return _synthesizer;
}

#pragma mark Speech

- (void)speak:(NSString*)text {
    
    
    // set up to speak
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[text copy]];
    
    // Get voice settings from model
    Voice *myVoice = [Voice sharedInstance];
    utterance.rate = [myVoice.rate floatValue];
    utterance.pitchMultiplier = [myVoice.pitch floatValue];
    utterance.volume = [myVoice.volume floatValue];
    
    utterance.voice = self.synthesisVoice;
    
    [self.synthesizer speakUtterance:utterance];
    
}

- (void)stopSpeech
{
    if ([self.synthesizer isSpeaking]) {
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        
        // Workaround for a known Apple bug where the speech is not actually stopped with the previous call
        // http://stackoverflow.com/questions/19672814/an-issue-with-avspeechsynthesizer-any-workarounds
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@""];
        [self.synthesizer speakUtterance:utterance];
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        self.cancelled = YES;
    }
}

- (BOOL)isSpeaking
{
    return [self.synthesizer isSpeaking];
}

#pragma mark AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"finished utterance:  %@", utterance.speechString);
    if ( (self.delegate && [self.delegate respondsToSelector:@selector(appHasFinishedSpeaking)]) && (self.cancelled == NO) ) {
        [self.delegate appHasFinishedSpeaking];
    }
    else {
        self.cancelled = NO;    // don't report a canceled utterance
    }
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance
{
    // NOT RECEIVING THIS CALL BACK FOR SOME REASON - MAYBE RELATED TO THE APPLE BUG ABOVE
    // WORKING AROUND WITH THE self.cancelled FLAG
    NSLog(@"canceled utterance: %@", utterance.speechString);
    self.cancelled = NO;
}

@end
