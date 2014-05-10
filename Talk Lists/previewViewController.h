//
//  previewTableViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 4/27/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Guide+Addendums.h"
#include "Step.h"

@interface previewViewController : UIViewController

@property (nonatomic, strong) Guide *guideToPreview;
@property (nonatomic, strong) NSString *titleToPreview;
@property (nonatomic, strong) Step *stepToPreview;

@end

