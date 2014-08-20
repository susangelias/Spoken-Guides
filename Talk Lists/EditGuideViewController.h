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

typedef NS_ENUM(NSUInteger, swipeDirection) {
    Left,
    Right
};

@interface EditGuideViewController : UIViewController

@property (strong, nonatomic) PFGuide *guideToEdit;
@property (strong, nonatomic) UIImage *downloadedGuideImage;
@property (weak, nonatomic) id <EditGuideViewControllerDelegate> editGuideDelegate;
@property int stepNumber;

- (IBAction)doneButtonPressed:(UIButton *)sender;

@end
