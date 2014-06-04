//
//  titleView.m
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "titleView.h"
#import "UITextField+SlideViews.h"

@implementation titleView
{
    BOOL returnKeyPressed;
}

-(void)showTitle
{
    BOOL editFlag;
    if (self.titleText) {
        editFlag = NO;
    }
    else {
        editFlag = YES;
    }
    [self.userEntryField slideViewRightOnScreenWithText:self.titleText toEdit:editFlag];
}

-(void)hideTitle
{
    [self.userEntryField slideViewLeftOffScreen];
}

#pragma mark <UITextFieldDelegate>

-(titleView *)initWithTextField: (UITextField *)textField withText: (NSString *)textContent
{
    self = [super init];
    if (self) {
        self.userEntryField = textField;
        self.userEntryField.delegate = self;
        if (textContent) {
            self.userEntryField.text = textContent;
        }
        else {
            self.userEntryField.placeholder = @"Enter Title Here";
            [self.userEntryField becomeFirstResponder];
        }
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
        [self.guideTitleDelegate titleCompleted:textField.text];
        [self.userEntryField slideViewLeftOffScreen];
    }
}

@end
