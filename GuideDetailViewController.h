//
//  GuideDetailViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 4/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideContents.h"

@interface GuideDetailViewController : UIViewController

@property (strong, nonatomic) NSString *guideTitle;
@property (strong, nonatomic) GuideContents *guide;

@end
