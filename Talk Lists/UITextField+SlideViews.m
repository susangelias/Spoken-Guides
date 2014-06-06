//
//  UITextField+SlideViews.m
//  Talk Lists
//
//  Created by Susan Elias on 5/24/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "UITextField+SlideViews.h"

@implementation UITextField (SlideViews)

-(void)slideViewLeftOffScreen
{
    // Slide our text field view offscreen to the left
    __weak   typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.50
                          delay:0.00
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.center = CGPointMake(weakSelf.center.x - 300, weakSelf.center.y);
                     }
                     completion:^(BOOL finished) {
                         weakSelf.hidden = YES;
                         // reset view to center of screen so that it is in a known position for
                         // subsequent moves (home position)
                         weakSelf.center = CGPointMake(self.center.x + 300, self.center.y);
                     }];
}

-(void)slideViewLeftOnScreenWithText:(NSString *)textContent toEdit:(bool)edit
{
    // Slide our text field view onscreen from the right
    // set starting point center off screen to the left
    self.center = CGPointMake(self.center.x - 300, self.center.y);
    __weak   typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.center = CGPointMake(weakSelf.center.x + 300, weakSelf.center.y);
                         weakSelf.text = textContent;
                         weakSelf.hidden = NO;
                     }
                     completion:^(BOOL finished) {
                         if (edit == YES) {
                             [weakSelf becomeFirstResponder];
                         }
                     }];
}


@end
