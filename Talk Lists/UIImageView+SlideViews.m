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
                         weakSelf.center = CGPointMake(self.center.x + 300, self.center.y);
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
                         weakSelf.center = CGPointMake(self.center.x + 300, self.center.y);
                     }
                     completion:^(BOOL finished) {
                         weakSelf.hidden = YES;
                         // reset view to center of screen so that it is in a known position for
                         // subsequent moves (home position)
                         weakSelf.center = CGPointMake(self.center.x - 300, self.center.y);
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
    
}

-(void)slideViewFromRightOnScreenWithPhoto:(UIImage *)photoImage
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
                         weakSelf.image = photoImage;
                         weakSelf.center = CGPointMake(self.center.x - 300, self.center.y);
                         //      [weakSelf bringSubviewToFront:[weakSelf viewWithTag:100]];
                     }
                     completion:^(BOOL finished) {
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
}


-(void)retractViewVertically:(ChainAnimationBlock)completionBlock
{
    // set view to back from the storyboard, using the Editor menu
    __weak   typeof (self) weakSelf = self;
    __block CGRect originalFrame = weakSelf.frame;
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                       //  weakSelf.center = CGPointMake(weakSelf.center.x, weakSelf.center.y - 110);
                         weakSelf.frame = CGRectMake(originalFrame.origin.x,originalFrame.origin.y, 0, 0);
                     }
                     completion:^(BOOL finished) {
                     //   weakSelf.center = CGPointMake(weakSelf.center.x, weakSelf.center.y + 110);
                         weakSelf.frame = originalFrame;
                       //  weakSelf.image = nil;
                        if (completionBlock) {
                             completionBlock();
                         }
                     }];
   
}

-(void)deployViewVertically:(UIImage *)imageContent
{
    // move view down so that it is visable in the view
 //   self.center = CGPointMake(self.center.x, self.center.y - 110);
    __block CGRect originalFrame = self.frame;
    self.frame = CGRectMake(originalFrame.origin.x,originalFrame.origin.y, 0, 0);
 //   self.hidden = NO;
    __weak   typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.50
                          delay:.55
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                       //  weakSelf.center = CGPointMake(weakSelf.center.x, weakSelf.center.y + 110);
                         weakSelf.frame = CGRectMake(originalFrame.origin.x,originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
                         weakSelf.image = imageContent;
                     }
                     completion:^(BOOL finished) {
            
                     }];
    
}

@end
