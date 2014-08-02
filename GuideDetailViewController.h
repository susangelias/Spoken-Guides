//
//  GuideDetailViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 4/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PFGuide.h"
#import "EditGuideViewControllerDelegate.h"

@interface GuideDetailViewController : UIViewController

@property (weak, nonatomic) PFGuide *guide;
@property (nonatomic, strong) NSNumber *currentLine;
@property (weak, nonatomic) id <EditGuideViewControllerDelegate> editGuideDelegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end
