//
//  titleView.h
//  Talk Lists
//
//  Created by Susan Elias on 5/6/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "titleViewDelegate.h"

@interface titleView : NSObject <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *userEntryField;
@property (nonatomic, weak) id <titleViewDelegate> guideTitleDelegate;

-(titleView *)initWithTextField: (UITextField *)textField;

@end
