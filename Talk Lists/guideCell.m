//
//  guideCellTableViewCell.m
//  Talk Lists
//
//  Created by Susan Elias on 5/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "guideCell.h"


@implementation guideCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
        self.textLabel.textColor = [UIColor whiteColor];
      //  self.backgroundColor = [UIColor colorWithRed:250.0/255 green:235.0/255 blue:215.0/255 alpha:1.0];
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Position and size the image view to get a square thumbnail size image
    float y = (78.0 - 69.0)/2.0;
    self.imageView.frame = CGRectMake(y,y,69,69);

}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
