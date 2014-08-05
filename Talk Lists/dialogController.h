//
//  dialogController.h
//  speech
//
//  Created by Susan Elias on 3/9/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
//#import "Guide+Addendums.h"
#import "ListeningController.h"
#import "SpeakingController.h"
#import "dialogControllerDelegate.h"
#import "PFGuide.h"

@interface dialogController : NSObject <ListeningControllerDelegate, SpeakingControllerDelegate >

@property (nonatomic, weak) id <dialogControllerDelegate> dialogControlDelegate;
@property (nonatomic) int currentLineIndex;
@property (nonatomic, strong) PFGuide *guide;

- (void)startDialog;
- (void)pauseDialog;
- (void)resumeDialog;
- (void)initializeDialog;
- (void)recoverFromAudioResetNotification;
- (void)speakLine;
-(void)stopAllAudio;
- (void)suspendAllAudio;

@end

