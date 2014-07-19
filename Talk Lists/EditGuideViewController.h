//
//  EditGuideViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 5/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Guide+Addendums.h"
#import "PFGuide.h"
#import "EditGuideViewControllerDelegate.h"

@interface EditGuideViewController : UIViewController

@property (strong, nonatomic) PFGuide *guideToEdit;
@property (strong, nonatomic) UIImage *downloadedGuideImage;
@property (weak, nonatomic) id <EditGuideViewControllerDelegate> editGuideDelegate;

//-(void)titleCompleted:(NSString *)title;
- (IBAction)doneButtonPressed:(UIButton *)sender;
//-(void) stepInstructionEntryCompleted: (NSString *)instructionText;
//-(void) stepInstructionTextChanged: (NSRange)range withReplacementText: (NSString *)instructionText;
//-(void) stepInstructionEditingEnded: (NSString *)instructionText;

@end
