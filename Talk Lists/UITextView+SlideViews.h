//
//  UITextView+SlideViews.h
//  Talk Lists
//
//  Created by Susan Elias on 5/24/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ ChainAnimationBlock)(void);

@interface UITextView (SlideViews)

-(void)slideViewToLeftOffScreen:(ChainAnimationBlock)completionBlock;
-(void)slideViewFromLeftOnScreenWithText:(NSString *)textContent
                               toEdit:(bool)edit
                  withCompletionBlock:(ChainAnimationBlock)completionBlock;

-(void)slideViewFromRightOnScreenWithText:(NSString *)textContent
                              toEdit:(BOOL)edit
                withCompletionBlock:(ChainAnimationBlock)completionBlock;
-(void)slideViewToRightOffScreen;

@end
