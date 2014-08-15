//
//  leftRightSegue.m
//  Talk Lists
//
//  Created by Susan Elias on 8/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "leftRightSegue.h"

@implementation leftRightSegue

-(void) perform
{
    // push the view controller from left to right
    
    UIViewController *source = self.sourceViewController;
    CGRect sourceFrame = source.view.frame;
    UIViewController *destination = self.destinationViewController;
    CGRect startingDestFrame = destination.view.frame;
    CGRect endingDestFrame = CGRectMake(startingDestFrame.origin.x-300, startingDestFrame.origin.y, startingDestFrame.size.width, startingDestFrame.size.height);
    
    [UIView animateWithDuration:0.60
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         source.view.frame = CGRectMake(sourceFrame.origin.x+300, sourceFrame.origin.y, sourceFrame.size.width, sourceFrame.size.height);
                         destination.view.frame = endingDestFrame;
                     } completion:^(BOOL finished) {
                         [source.navigationController pushViewController:destination animated:NO];
                     }];
 }
@end
