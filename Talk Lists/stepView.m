//
//  stepEntryView.m
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "stepView.h"
#import "UITextView+SlideViews.h"

@implementation stepView
//@synthesize textViewPlaceholder;

-(stepView *)initWithPrimaryTextView: (UITextView *)primaryTextView secondaryTextView: (UITextView *) swapTextView
{
    
    self = [super init];
    if (self)
    {
        self.stepTextView = primaryTextView;
        self.swapTextView = swapTextView;
        self.stepTextView.delegate = self;
        self.swapTextView.delegate = self;
    }
    return self;
}

-(void)updateLeftStepEntryView: (NSString *)textContent
{
    BOOL editFlag = NO;
    if (!textContent) {
        // no content so is a new step entry, set editflag to activate keyboard and display placeholder text
        editFlag = YES;
    }
    __weak  typeof (self) weakSelf = self;
    ChainAnimationBlock animationComplete = ^{
        UITextView *temp = self.stepTextView;
        weakSelf.stepTextView = self.swapTextView;
        weakSelf.swapTextView = temp;
        weakSelf.textViewPlaceholder.hidden = ~editFlag;
    };

    [self.stepTextView slideViewLeftOffScreen:nil];
    [weakSelf.swapTextView slideViewLeftOnScreenWithText:textContent
                                                  toEdit:editFlag
                                     withCompletionBlock:animationComplete];
}

-(void)updateRightStepEntryView: (NSString *)textContent
{
    // there is text content already so this is not a new step
    __weak  typeof (self) weakSelf = self;
    ChainAnimationBlock animationComplete = ^{
        UITextView *temp = self.stepTextView;
        weakSelf.stepTextView = self.swapTextView;
        weakSelf.swapTextView = temp;
    };

    [self.stepTextView slideViewRightOffScreen];
    [self.swapTextView slideViewRightOnScreenWithText:textContent
                                               toEdit:NO
                                  withCompletionBlock:animationComplete];
}

-(void)hideStepEntryView
{
    [self.stepTextView slideViewRightOffScreen];
    [self.swapTextView slideViewRightOffScreen];
    
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
        [self.stepEntryDelegate stepInstructionTextChanged:self.stepTextView.text];
        return YES;
    }
}


-(void)textViewDidBeginEditing:(UITextView *)textView {
    // clear the placeholder text
    self.textViewPlaceholder.hidden = YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    self.textViewPlaceholder.hidden = ([textView.text length] > 0);
}


@end
