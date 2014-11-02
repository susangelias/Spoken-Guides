//
//  GuideQueryTableViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 7/13/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Parse/Parse.h>
#import "PFGuide.h"
#import "GuideQueryTableViewControllerDelegate.h"
#import "guideCell.h"
#import "stepCell.h"

@interface GuideQueryTableViewController : PFQueryTableViewController

@property (nonatomic, weak) PFGuide *guide;
@property (nonatomic, weak) id <GuideQueryTableViewControllerDelegate> parentDelegate;

- (void)unhighlightCurrentLine:(int) lineNumber;
- (void)setTextColor:(UIColor *)highlightColor atIndexPath:(NSIndexPath *)lineNumber;
- (void)setStepAccessToPublic:(BOOL)publicAccessFlag;
- (void)refreshUIForRowSelectionAtIndexPath:(NSIndexPath *)indexPath;
- (stepCell *)stepCellAtLineNumber:(int)lineNumber;

@end
