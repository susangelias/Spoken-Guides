//
//  stepEntryView.m
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "stepView.h"
#import "UITextView+SlideViews.h"
#import "SZTextView.h"

@implementation stepView
//@synthesize textViewPlaceholder;

-(stepView *)initWithPrimaryTextView: (SZTextView *)primaryTextView secondaryTextView: (SZTextView *) swapTextView
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
    else {
        self.stepTextView.placeholder = @"";
    }
    __weak  typeof (self) weakSelf = self;
    ChainAnimationBlock animationComplete = ^{
        SZTextView *temp = self.stepTextView;
        weakSelf.stepTextView = self.swapTextView;
        weakSelf.swapTextView = temp;
      //  weakSelf.textViewPlaceholder.hidden = !editFlag;
     //   NSLog(@"hidden %d", weakSelf.textViewPlaceholder.hidden);
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
        SZTextView *temp = self.stepTextView;
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
 //   self.textViewPlaceholder.hidden = YES;
    
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

/*
-(void)textViewDidBeginEditing:(UITextView *)textView {
    // clear the placeholder text
  //  self.textViewPlaceholder.hidden = YES;
}
*/
/*
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] > 0) {
        self.stepTextView.placeholder = @"";
    }
}
 */


@end
