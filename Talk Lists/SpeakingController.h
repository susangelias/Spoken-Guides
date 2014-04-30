//
//  textSpeechController.h
//  speech
//
//  Created by Susan Elias on 3/9/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SpeakingController : NSObject <AVSpeechSynthesizerDelegate>

@property (nonatomic, weak) id delegate;

- (void)speak:(NSString*)text;
- (void)stopSpeech;
- (BOOL)isSpeaking;

@end

@protocol SpeakingControllerDelegate <NSObject>

- (void) appHasFinishedSpeaking;

@end