//
//  stepEntryView.h
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "stepEntryViewDelegate.h"
#import "SZTextView.h"
#import "UITextView+SlideViews.h"

@interface stepView : NSObject <UITextViewDelegate>

@property (nonatomic, weak) id <stepViewDelegate> stepEntryDelegate;
@property (weak, nonatomic)  SZTextView *stepTextView;
@property (weak, nonatomic) UIImageView *stepImageView;
@property (weak, nonatomic)  SZTextView *swapTextView;
@property (weak, nonatomic) UIImageView *swapImageView;


-(stepView *)initWithPrimaryTextView: (SZTextView *) primaryTextView
                   secondaryTextView: (SZTextView *) swapTextView
                withPrimaryImageView: (UIImageView *) primaryImageView
              withSecondaryImageView: (UIImageView *) secondaryImageView;
-(void)updateLeftSwipeStepEntryView: (NSString *)textContent withPhoto: (UIImage *)photo;
-(void)updateRightSwipeStepEntryView: (NSString *)textContent withPhoto: (UIImage *)photo;
-(void)hideStepEntryView;

@end
