//
//  GuideDetailViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 4/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Guide.h"

@interface GuideDetailViewController : UIViewController

@property (weak, nonatomic) Guide *guide;
@property (nonatomic, strong) NSNumber *currentLine;

@end
