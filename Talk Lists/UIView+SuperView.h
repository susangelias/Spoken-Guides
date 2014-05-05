//
//  UIView+SuperView.h
//  Talk Lists
//
//  Created by Susan Elias on 5/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SuperView)

-(UIView *)findSuperViewWithClass:(Class)superViewClass;

@end
