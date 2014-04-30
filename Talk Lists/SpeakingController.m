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

@end

@implementation SpeakingController

#pragma mark Initializations

- (AVSpeechSynthesisVoice *)synthesisVoice
{
    if (!_synthesisVoice)
    {
        _synthesisVoice = [AVSpeechSynthesisVoice voiceWithLanguage:[[NSLocale preferredLanguages] objectAtIndex:0]];
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
   // NSLog(@"Utterance %@", utterance);
    
    [self.synthesizer speakUtterance:utterance];
    
}

- (void)stopSpeech
{
    if([self.synthesizer isSpeaking]) {
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@""];
        [self.synthesizer speakUtterance:utterance];
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

- (BOOL)isSpeaking
{
    return [self.synthesizer isSpeaking];
}

#pragma mark AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(appHasFinishedSpeaking)]) {
        [self.delegate appHasFinishedSpeaking];
    }
}

@end
