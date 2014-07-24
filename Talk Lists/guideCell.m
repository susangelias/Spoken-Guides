//
//  guideCellTableViewCell.m
//  Talk Lists
//
//  Created by Susan Elias on 5/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "guideCell.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation guideCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    //    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Position and size the image view
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
