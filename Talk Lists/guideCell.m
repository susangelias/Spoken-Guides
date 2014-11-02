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
        self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
 
    self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.textLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
     
    // make sure the text starts on the left
    self.textLabel.frame = CGRectMake(20, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    self.textLabel.numberOfLines = 0;
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
