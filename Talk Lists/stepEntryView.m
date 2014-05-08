//
//  stepEntryView.m
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "stepEntryView.h"

@implementation stepEntryView
@synthesize textViewPlaceholder;

-(stepEntryView *)initWithPrimaryTextView: (UITextView *)primaryTextView secondaryTextView: (UITextView *) swapTextView
{
    
    self = [super init];
    if (self)
    {
        self.stepTextView = primaryTextView;
        self.swapTextView = swapTextView;
        self.stepTextView.delegate = self;
        
        // Slide in new view
        self.stepTextView.center = CGPointMake(self.stepTextView.center.x + 300, self.stepTextView.center.y);
        [UIView animateWithDuration:0.75
                              delay:0.1
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             self.stepTextView.hidden = NO;
                             self.stepTextView.center = CGPointMake(self.stepTextView.center.x - 300, self.stepTextView.center.y);
                         }
                         completion:^(BOOL finished) {
                             [self.stepTextView becomeFirstResponder];
                             self.stepTextView.delegate = self;
                             self.textViewPlaceholder.hidden = NO;  // move to stepView class
                         }];

    }
    return self;
}

#pragma mark    <UITextViewDelegate>

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        [self.stepEntryDelegate stepInstructionEntered:self.stepTextView.text];
        
        // swap the step views
        self.swapTextView.center = CGPointMake(self.stepTextView.center.x + 300, self.stepTextView.center.y);
        [UIView animateWithDuration:0.50
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.stepTextView.center = CGPointMake(self.stepTextView.center.x - 300, self.stepTextView.center.y);
                             self.stepTextView.hidden = YES;
                             self.swapTextView.hidden = NO;
                             self.swapTextView.center = CGPointMake(self.swapTextView.center.x - 300, self.swapTextView.center.y);
                             // clear the photo image
                          //   self.imageView.image = nil;
                         }
                         completion:^(BOOL finished) {
                             // Then clear the text view for the next step entry
                             self.stepTextView.text = @"";
                             // Then swap the views
                             UITextView *temp = self.stepTextView;
                             self.stepTextView = self.swapTextView;
                             self.swapTextView = temp;
                             [self.stepTextView becomeFirstResponder];
                             self.stepTextView.delegate = self;
                             self.textViewPlaceholder.hidden = NO;
                             
                         }];
        
        return NO;
    }
    else {
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
