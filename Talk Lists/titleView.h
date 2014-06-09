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

@property (nonatomic, weak) UITextField *titleTextField;
@property (nonatomic, weak) UIImageView *titleImageView;
@property (nonatomic, weak) id <titleViewDelegate> guideTitleDelegate;

-(titleView *)initWithTextField: (UITextField *)textField
                  withImageView: (UIImageView *)imageView;
-(void)updateRightSwipeTitleEntryView: (NSString *)textContent withPhoto:(UIImage *)photo;
-(void)updateStaticTitleEntryView:(NSString *)textContent withPhoto: (UIImage *)photoImage;
-(void)hideTitleView;

@end
