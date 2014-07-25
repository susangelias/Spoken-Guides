//
//  DataEntryContainerViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 7/18/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DataEntryDelegate.h"
#import "DataEntryViewController.h"
#import "EditGuideViewController.h"

#define SegueIdentifierFirst @"embedFirst"
#define SegueIdentifierSecond @"embedSecond"

@interface DataEntryContainerViewController : UIViewController

@property (weak, nonatomic) DataEntryViewController *currentDataEntryVC;
@property (weak, nonatomic)  NSString *entryText;
@property (weak, nonatomic) UIImage *entryImage;
@property int entryNumber;
@property swipeDirection entryTransistionDirection;
@property (weak, nonatomic) id <DataEntryDelegate> dataEntryDelegate;

-(void)swapViewControllers;

@end
