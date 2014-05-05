//
//  UIView+SuperView.m
//  Talk Lists
//
//  Created by Susan Elias on 5/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "UIView+SuperView.h"

@implementation UIView (SuperView)

-(UIView *)findSuperViewWithClass:(Class)superViewClass
{
    UIView *superView = self.superview;
    UIView *foundSuperView = nil;
    
    while ((nil != superView) && (nil == foundSuperView)) {
        if ([superView isKindOfClass:superViewClass]) {
            foundSuperView = superView;
        }
        else {
            superView = superView.superview;
        }
    }
    return foundSuperView;
}

@end
