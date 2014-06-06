//
//  UIImageView+SlideViews.m
//  Talk Lists
//
//  Created by Susan Elias on 6/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "UIImageView+SlideViews.h"

@implementation UIImageView (SlideViews)

-(void)slideViewToLeftOffScreen: (ChainAnimationBlock) completionBlock
{
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.center = CGPointMake(weakSelf.center.x - 300, weakSelf.center.y);
                     }
                     completion:^(BOOL finished) {
                         weakSelf.hidden = YES;
                         // reset view to center of screen so that it is in a known position for
                         // subsequent moves (home position)
                         weakSelf.center = CGPointMake(weakSelf.center.x + 300, weakSelf.center.y);
                         weakSelf.image = nil;
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
    
}

-(void)slideViewFromLeftOnScreenWithPhoto:(UIImage *)photoImage
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
                         weakSelf.image = photoImage;
                         weakSelf.center = CGPointMake(weakSelf.center.x + 300, weakSelf.center.y);
                     }
                     completion:^(BOOL finished) {
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
}

-(void)slideViewToRightOffScreen: (ChainAnimationBlock) completionBlock
{
    __weak typeof (self) weakSelf = self;
    
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.center = CGPointMake(weakSelf.center.x + 300, weakSelf.center.y);
                     }
                     completion:^(BOOL finished) {
                         weakSelf.hidden = YES;
                         // reset view to center of screen so that it is in a known position for
                         // subsequent moves (home position)
                         weakSelf.center = CGPointMake(weakSelf.center.x - 300, weakSelf.center.y);
                         weakSelf.image = nil;
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
    
}

-(void)slideViewFromRightOnScreenWithPhoto:(UIImage *)photoImage
                 withCompletionBlock:(ChainAnimationBlock)completionBlock
{
    // to start set the center off screen to the right
    self.center = CGPointMake(self.center.x + 300, self.center.y);
    
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.hidden = NO;
                         weakSelf.image = photoImage;
                         weakSelf.center = CGPointMake(weakSelf.center.x - 300, weakSelf.center.y);
                     }
                     completion:^(BOOL finished) {
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
}


@end
