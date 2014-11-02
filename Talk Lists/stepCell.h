//
//  stepCell.h
//  Talk Lists
//
//  Created by Susan Elias on 5/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFStep.h"

#define kStepCellFontSize 18.0
#define kStepCellStdHeight 78.0
#define kStepCellStdWidthNoImage 300.0
#define kStepCellStdWidthWithImage 248.0

extern NSString *const kStepCellFont;

@interface stepCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *stepImageView;

-(void)configureStepCell: (PFStep *)stepToDisplay attributes:(NSDictionary *)stepAttributes;
-(void) enlargeImage;
-(void) shrinkImage;

@end
