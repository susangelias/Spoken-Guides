//
//  UITextField+SlideViews.h
//  Talk Lists
//
//  Created by Susan Elias on 5/24/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (SlideViews)

-(void)slideViewLeftOffScreen;
-(void)slideViewRightOnScreenWithText:(NSString *)textContent toEdit:(bool)edit;

@end
