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
@property (nonatomic, strong) NSString *titleText;

-(titleView *)initWithTextField: (UITextField *)textField withText: (NSString *)textContent;
-(void)showTitle;
-(void)hideTitle;

@end
