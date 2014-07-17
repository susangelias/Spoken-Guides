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

/*
-(void)configureGuideCell: (PFGuide *)guideToDisplay
{
    self.textLabel.text = guideToDisplay.title;

    if (guideToDisplay.image) {
        // Set the thumbnail as the displayed image for now but better resolution image will get swapped in in the completion block
        self.imageView.file = guideToDisplay.thumbnail;
        self.imageView.image = [UIImage imageNamed:@"image.png"];
    }
     
    if (guideToDisplay.photo.thumbnail) {
        // Set the thumbnail as the displayed image for now but better resolution image will get swapped in in the completion block
        self.imageView.image = [UIImage imageWithData:guideToDisplay.photo.thumbnail];
        
        // Retrieve the photo so it can be displayed in the delegate method - this puts an image suitable
        // for full screen display into our thumbnail shown in the table view so when the user taps it
        // and it expands to full screen it will not be blurry as it is if I use the thumbnail here
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        __weak typeof(self)weakSelf = self;
        [library getImageForAssetURL:[NSURL URLWithString:guideToDisplay.photo.assetLibraryURL]
                 withCompletionBlock:^(UIImage *image, NSError *error) {
                     weakSelf.imageView.image = image;
                 }];
      }
    else {
        self.imageView.image = nil;
    }
}

*/
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
