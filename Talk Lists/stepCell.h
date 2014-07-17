//
//  stepCell.h
//  Talk Lists
//
//  Created by Susan Elias on 5/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Step+Addendums.h"
#import "PFStep.h"

@interface stepCell : PFTableViewCell

-(void)configureStepCell: (PFStep *)stepToDisplay;

@end
