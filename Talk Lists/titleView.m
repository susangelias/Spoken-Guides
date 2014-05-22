//
//  titleView.m
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "titleView.h"

@implementation titleView
{
    BOOL returnKeyPressed;
}

#pragma mark <UITextFieldDelegate>

-(titleView *)initWithTextField: (UITextField *)textField
{
    self = [super init];
    if (self) {
        self.userEntryField = textField;
        self.userEntryField.delegate = self;
        [self.userEntryField becomeFirstResponder];
    }
    return self;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    returnKeyPressed = NO;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    returnKeyPressed = YES;
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (returnKeyPressed) {
        // Send entered text to delegate
        [self.guideTitleDelegate titleEntered:textField.text];
        
        // Slide our text field view offscreen to the left
        __weak   typeof (self) weakSelf = self;
        [UIView animateWithDuration:0.75
                              delay:0.1
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             weakSelf.userEntryField.center = CGPointMake(self.userEntryField.center.x - 300, self.userEntryField.center.y);
                         }
                         completion:^(BOOL finished) {
                             weakSelf.userEntryField.hidden = YES;
                    }];
    }
}

@end
