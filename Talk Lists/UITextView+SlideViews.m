//
//  UITextView+SlideViews.m
//  Talk Lists
//
//  Created by Susan Elias on 5/24/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "UITextView+SlideViews.h"

@implementation UITextView (SlideViews)


-(void)slideViewToLeftOffScreen:(ChainAnimationBlock)completionBlock
{
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.center = CGPointMake(self.center.x - 300, self.center.y);
                      }
                     completion:^(BOOL finished) {
                         weakSelf.hidden = YES;
                         // reset view to center of screen so that it is in a known position for
                         // subsequent moves (home position)
                         weakSelf.center = CGPointMake(self.center.x + 300, self.center.y);
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
    
}

-(void)slideViewFromLeftOnScreenWithText:(NSString *)textContent
                               toEdit:(bool)edit
                  withCompletionBlock:(ChainAnimationBlock)completionBlock
{
    // set starting point center off screen to the left
    self.center = CGPointMake(self.center.x - 300, self.center.y);

    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.hidden = NO;
                        weakSelf.text = textContent;
                         weakSelf.center = CGPointMake(self.center.x + 300, self.center.y);
                     }
                     completion:^(BOOL finished) {
                         if (edit == YES) {
                             [weakSelf becomeFirstResponder];
                         }
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
}

-(void)slideViewFromRightOnScreenWithText:(NSString *)textContent
                              toEdit:(BOOL)edit
                 withCompletionBlock:(ChainAnimationBlock)completionBlock
{
    // set the center off screen to the right
    self.center = CGPointMake(self.center.x + 300, self.center.y);

    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.hidden = NO;
                         weakSelf.text = textContent;
                         weakSelf.center = CGPointMake(self.center.x - 300, self.center.y);
                   //      [weakSelf bringSubviewToFront:[weakSelf viewWithTag:100]];
                     }
                     completion:^(BOOL finished) {
                         if (edit == YES) {
                             [weakSelf becomeFirstResponder];
                         }
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
}

-(void)slideViewToRightOffScreen
{
    __weak typeof (self) weakSelf = self;

    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.center = CGPointMake(self.center.x + 300, self.center.y);
                     }
                     completion:^(BOOL finished) {
                         weakSelf.hidden = YES;
                         // reset view to center of screen so that it is in a known position for
                         // subsequent moves (home position)
                         weakSelf.center = CGPointMake(self.center.x - 300, self.center.y);
                     }];
    
}

@end
