//
//  stepEntryView.h
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "stepEntryViewDelegate.h"

@interface stepEntryView : NSObject <UITextViewDelegate>

@property (nonatomic, weak) id <stepEntryViewDelegate> stepEntryDelegate;
@property (weak, nonatomic)  UITextView *stepTextView;
@property (weak, nonatomic)  UITextView *swapTextView;
@property (weak, nonatomic)  UILabel *textViewPlaceholder;

-(stepEntryView *)initWithPrimaryTextView: (UITextView *)primaryTextView secondaryTextView: (UITextView *) swapTextView;

@end
