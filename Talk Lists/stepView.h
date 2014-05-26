//
//  stepEntryView.h
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "stepEntryViewDelegate.h"

@interface stepView : NSObject <UITextViewDelegate>

@property (nonatomic, weak) id <stepViewDelegate> stepEntryDelegate;
@property (weak, nonatomic)  UITextView *stepTextView;
@property (weak, nonatomic)  UITextView *swapTextView;
@property (weak, nonatomic)  UILabel *textViewPlaceholder;

-(stepView *)initWithPrimaryTextView: (UITextView *)primaryTextView secondaryTextView: (UITextView *) swapTextView;
-(void)updateLeftStepEntryView: (NSString *)textContent;
-(void)updateRightStepEntryView: (NSString *)textContent;
-(void)hideStepEntryView;

@end
