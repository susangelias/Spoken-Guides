//
//  UIImageView+SlideViews.h
//  Talk Lists
//
//  Created by Susan Elias on 6/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ ChainAnimationBlock)(void);

@interface UIImageView (SlideViews)

-(void)slideViewToLeftOffScreen: (ChainAnimationBlock) completionBlock;
-(void)slideViewFromLeftOnScreenWithPhoto:(UIImage *)photoImage
                      withCompletionBlock:(ChainAnimationBlock)completionBlock;
-(void)slideViewToRightOffScreen: (ChainAnimationBlock) completionBlock;
-(void)slideViewFromRightOnScreenWithPhoto:(UIImage *)photoImage
                       withCompletionBlock:(ChainAnimationBlock)completionBlock;

@end
