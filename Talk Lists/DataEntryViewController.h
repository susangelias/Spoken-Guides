//
//  StepEntryViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 7/17/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SZTextView.h"
#import "DataEntryDelegate.h"

@interface DataEntryViewController : UIViewController

@property (weak, nonatomic)  NSString *entryText;
@property (strong, nonatomic)  UIImage *entryImage;
@property int entryNumber;
@property (weak, nonatomic) id <DataEntryDelegate> dataEntryDelegate;

-(void)imageLoaded:(UIImage *)downloadedImage;
-(void)viewAboutToChange;

@end
