//
//  dialogControllerDelegate.h
//  Talk Lists
//
//  Created by Susan Elias on 5/19/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol dialogControllerDelegate <NSObject>

@required
- (void)dialogComplete;
- (void)setCurrentLine:(NSNumber *) lineNumber;
- (void)dialogStartedListening;
- (void)dialogStoppedListening;
- (void)dialogDecodingSpeech;
- (void)dialogComprehendedSpeech;
- (void)dialogFailedToComprehendSpeech;

@optional
- (void)dialogHeardText:(NSString *) heardText;

@end