//
//  EditGuideViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 5/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Guide+Addendums.h"
#import "PFGuide.h"

@interface EditGuideViewController : UIViewController

@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;
//@property (strong, nonatomic) Guide *guideToEdit;
@property (strong, nonatomic) PFGuide *guideToEdit;
@property (strong, nonatomic) NSMutableArray *steps;

-(void)titleCompleted:(NSString *)title;
- (IBAction)doneButtonPressed:(UIButton *)sender;
-(void) stepInstructionEntryCompleted: (NSString *)instructionText;
-(void) stepInstructionTextChanged: (NSRange)range withReplacementText: (NSString *)instructionText;
-(void) stepInstructionEditingEnded: (NSString *)instructionText;

@end
