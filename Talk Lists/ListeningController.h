//
//  AudioInputViewController.h
//  AudioInput
//
//  Created by Susan Elias on 3/10/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OpenEarsEventsObserver.h>

typedef NS_ENUM(NSInteger, commandType) {
    PROCEED,
    REPEAT,
    GO_BACK
};

@interface ListeningController : NSObject <OpenEarsEventsObserverDelegate>

@property (nonatomic, weak) id delegate;

- (void) startListening;
- (void) stopListening;
- (BOOL) isListening;
- (void) suspendListening;
- (BOOL) isSuspended;
- (void) resumeListening;

- (ListeningController *) init;

@end

@protocol ListeningControllerDelegate <NSObject>

@required

- (void)userHasSpoken: (commandType) command;
- (void)startedListening;
- (void)stoppedListening;

@optional
- (void)userHasSpoken:(BOOL) proceed withText: (NSString *)heardText;
- (void)heardTextIgnored: (NSString *)heardText;

@end