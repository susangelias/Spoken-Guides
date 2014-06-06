//
//  stepEntryView.m
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "stepView.h"

#import "SZTextView.h"
#import "UIImageView+SlideViews.h"

@implementation stepView

-(stepView *)initWithPrimaryTextView: (SZTextView *) primaryTextView
                   secondaryTextView: (SZTextView *) swapTextView
                withPrimaryImageView: (UIImageView *) primaryImageView
              withSecondaryImageView: (UIImageView *) secondaryImageView
{
    
    self = [super init];
    if (self)
    {
        self.stepTextView = primaryTextView;
        self.swapTextView = swapTextView;
        self.stepImageView = primaryImageView;
        self.swapImageView = secondaryImageView;
        self.stepImageView.hidden = NO;
        self.swapImageView.hidden = NO;
        self.stepTextView.delegate = self;
        self.swapTextView.delegate = self;

    }
    return self;
}

-(void)updateLeftSwipeStepEntryView: (NSString *)textContent withPhoto: (UIImage *)photo
{
    BOOL editFlag = NO;
    if (!textContent) {
        // no content so is a new step entry, set editflag to activate keyboard and display placeholder text
        editFlag = YES;
    }
    else {
        self.stepTextView.placeholder = @"";
    }
    __weak  typeof (self) weakSelf = self;
    ChainAnimationBlock animationComplete = ^{
        SZTextView *tempTextView = self.stepTextView;
        weakSelf.stepTextView = self.swapTextView;
        weakSelf.swapTextView = tempTextView;
        UIImageView *tempImageView = self.stepImageView;
        weakSelf.stepImageView = self.swapImageView;
        weakSelf.swapImageView = tempImageView;
    };

    [self.stepTextView slideViewToLeftOffScreen:nil];
    [self.stepImageView slideViewToLeftOffScreen:nil];

    if (photo) {
        [self.swapImageView slideViewFromRightOnScreenWithPhoto:photo
                                       withCompletionBlock:nil];
    }
    [self.swapTextView slideViewFromRightOnScreenWithText:textContent
                                                  toEdit:editFlag
                                     withCompletionBlock:animationComplete];
}

-(void)updateRightSwipeStepEntryView: (NSString *)textContent withPhoto: (UIImage *)photo
{
    // there is text content already so this is not a new step
    __weak  typeof (self) weakSelf = self;
    ChainAnimationBlock animationComplete = ^{
        SZTextView *temp = self.stepTextView;
        weakSelf.stepTextView = self.swapTextView;
        weakSelf.swapTextView = temp;
        UIImageView *tempImageView = self.stepImageView;
        weakSelf.stepImageView = self.swapImageView;
        weakSelf.swapImageView = tempImageView;
    };

    [self.stepTextView slideViewToRightOffScreen];
    [self.stepImageView slideViewToRightOffScreen:nil];

    if (photo) {
        [self.swapImageView slideViewFromLeftOnScreenWithPhoto:photo
                                        withCompletionBlock:nil];
    }
    [self.swapTextView slideViewFromLeftOnScreenWithText:textContent
                                               toEdit:NO
                                  withCompletionBlock:animationComplete];
}

-(void)hideStepEntryView
{
    [self.stepTextView slideViewToRightOffScreen];
    [self.swapTextView slideViewToRightOffScreen];
    [self.stepImageView slideViewToRightOffScreen:nil];
    [self.swapImageView slideViewToRightOffScreen:nil];
}

#pragma mark    <UITextViewDelegate>

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self.stepEntryDelegate stepInstructionEntryCompleted:self.stepTextView.text];
        return NO;
    }
    else {
        // need to pass range and replacement text to delegate
        [self.stepEntryDelegate stepInstructionTextChanged:self.stepTextView.text];
        return YES;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self.stepEntryDelegate stepInstructionEditingEnded:textView.text];
}

@end
