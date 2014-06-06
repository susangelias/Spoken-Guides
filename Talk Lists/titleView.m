//
//  titleView.m
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "titleView.h"
#import "UITextField+SlideViews.h"
#import "UIImageView+SlideViews.h"

@implementation titleView
{
    BOOL returnKeyPressed;
}

-(void)updateRightSwipeTitleEntryView: (NSString *)textContent withPhoto:(UIImage *)photo
{
    // slide the title view on screen from the left
     [self.titleTextField slideViewLeftOnScreenWithText:textContent toEdit:NO];
    if (photo) {
        [self.titleImageView slideViewFromLeftOnScreenWithPhoto:photo
                                        withCompletionBlock:nil];
    }
}

-(void)updateStaticTitleEntryView: (NSString *)textContent withPhoto:(UIImage *)photo
{
    self.titleTextField.hidden = NO;
    if (textContent) {
        self.titleTextField.text = textContent;
    }
    else {
        self.titleTextField.placeholder = @"Enter Title Here";
        [self.titleTextField becomeFirstResponder];
    }
    if (photo) {
        self.titleImageView.image = photo;
    }
}


-(void)hideTitleView
{
    [self.titleTextField slideViewLeftOffScreen];
    [self.titleImageView slideViewToLeftOffScreen:nil];
}

#pragma mark <UITextFieldDelegate>

-(titleView *)initWithTextField: (UITextField *)textField
                  withImageView: (UIImageView *)imageView
{
    self = [super init];
    if (self) {
        self.titleTextField = textField;
        self.titleTextField.delegate = self;
        self.titleImageView = imageView;
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
        [self.titleTextField slideViewLeftOffScreen];
    }
}

@end
