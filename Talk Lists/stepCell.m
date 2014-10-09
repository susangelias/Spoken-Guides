//
//  stepCell.m
//  Talk Lists
//
//  Created by Susan Elias on 5/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "stepCell.h"
#import "UIView+SuperView.h"
#import "UIImage+Resize.h"

NSString *const kStepCellFont = @"HelveticaNeue-Thin";

@interface stepCell()

@property (strong, nonatomic) PFImageView *unzoomedCellImageView;

@end

@implementation stepCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialize cell text
        UIFont *stepCellFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.textLabel.font = stepCellFont;
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    // Calling initWithStyle is the only way I have found to get my stepCell to display an image
    // I'm not sure what is happening in initWithStyle that makes this happen
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stepCell"];
    return self;
}

- (void)awakeFromNib
{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Position and size the image view to get a square thumbnail size image on the right end of the cell
    CGRect tableViewCellFrame = self.frame;

    float y = (kStepCellStdHeight - 69.0)/2.0;
    float x =  (tableViewCellFrame.size.width - 72);
    self.imageView.frame = CGRectMake(x,y,69,69);
    
    if (self.imageView.file) {
        self.textLabel.frame = CGRectMake(15.0, 3.0, self.frame.size.width - 89.0, self.frame.size.height-0.5);
    } else {
        self.textLabel.frame = CGRectMake(15.0, 3.0, self.frame.size.width -30, self.frame.size.height-0.5);
     }
}

-(void)configureStepCell: (PFStep *)stepToDisplay attributes:(NSDictionary *)stepAttributes
{
    UITapGestureRecognizer *tapped;

    if (stepToDisplay.instruction) {
        self.textLabel.text = stepToDisplay.instruction;
        self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }

    UIImage *latestThumbnail = [stepAttributes objectForKey:kPFStepChangedThumbnail];
    if (latestThumbnail) {
        self.imageView.image = latestThumbnail;
        self.imageView.file = nil;
    }
    else if (stepToDisplay.thumbnail) {
        self.imageView.image = [UIImage imageNamed:@"image.png"];
        self.imageView.file = [stepToDisplay objectForKey:@"thumbnail"];
    }
    else {
        // since these cells are re-used, make sure old images are cleaned out
        self.imageView.image = nil;
        self.imageView.file = nil;
    }
    if (self.imageView.image) {
        // if there is a photo, get the hiRes image loaded in case the user wants to zoom the thumbnail
        self.unzoomedCellImageView.image = [stepAttributes objectForKey:kPFStepChangedImage];
        if (!self.unzoomedCellImageView.image) {
            self.unzoomedCellImageView.image = [UIImage imageNamed:@"image.png"];
            self.unzoomedCellImageView.file = [stepToDisplay objectForKey:@"image"];
        }
    }
    
    // Add Gesture Recognizer
    if (self.imageView.image) {
        tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellImageTapped:)];
        tapped.numberOfTapsRequired = 1;
        [self.imageView addGestureRecognizer:tapped];
        self.imageView.userInteractionEnabled = YES;
    }
    else {
        self.imageView.image = nil;
        [self.imageView removeGestureRecognizer:tapped];
    }
}


#pragma mark cell image enlargement management

- (void)cellImageTapped:(UITapGestureRecognizer *)gesture
{
    // Zooms the thumbnail photo to center screen, enlarged
    
    // save original location of unzoomed image
    // convert tapped image frame to superview coordinates
    CGPoint tappedImageCenterConverted = [self.viewForBaselineLayout convertPoint:self.imageView.center toView:self.superview.superview];
    self.unzoomedCellImageView.center = tappedImageCenterConverted;
    self.unzoomedCellImageView.bounds = self.imageView.bounds;

    // disable user touchs while zooming
    self.unzoomedCellImageView.userInteractionEnabled = NO;
 
    // create a new image view based on the origin of the unzoomed view
    __block UIImageView *viewToEnlarge = [[UIImageView alloc]initWithFrame:self.unzoomedCellImageView.frame];
    __weak typeof (self) weakSelf = self;
    
    // start downloading the hiRes image
    [self.unzoomedCellImageView loadInBackground:^(UIImage *image, NSError *error) {
        if (!error) {
            // save the hiRes image
            viewToEnlarge.image = image;
        }
        else {
            NSLog(@"ERROR DOWNLOADING HI RES IMAGE");
            // set to lo Res image
            viewToEnlarge.image = weakSelf.imageView.image;
        }
    }];
    
    // get pointer to the tableView that this cell belongs to
    UITableView *guideTableView = nil;
    UIView *superView = self.superview;
    while (nil != self.superview && nil == guideTableView) {
        if ([superView isKindOfClass:[UITableView class]]) {
            guideTableView = (UITableView *)superView;
        } else {
            superView = superView.superview;
        }
    }

    // get pointer to the view that the tableView belongs to
    UIView *myView = guideTableView.superview;
    
    // find the point in the center of the screen
    CGRect fullScreenRect = [[UIScreen mainScreen] applicationFrame];
    CGPoint fullScreenCenter = CGPointMake(fullScreenRect.size.width/2.0, fullScreenRect.size.height*1/3);
    CGRect enlargedBounds = CGRectMake(0, myView.frame.origin.y, fullScreenRect.size.width, fullScreenRect.size.width);
    
    // disable scrolling of the tableview so that can zoom photo back easily
    guideTableView.scrollEnabled = NO;

    [myView addSubview:viewToEnlarge];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         viewToEnlarge.center = fullScreenCenter;
                         viewToEnlarge.bounds =enlargedBounds;
                    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             // set tap gesture on enlarged photo view so that it can be shrunk back to original size
                             UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc]initWithTarget:weakSelf action:@selector(enlargedImageTapped:)];
                             [viewToEnlarge addGestureRecognizer:tapped];
                             viewToEnlarge.userInteractionEnabled = YES;
                         }
                     }];
}

-(void)enlargedImageTapped:(UITapGestureRecognizer *)gesture
{
    // Shrinkg the enlarged image back down to the thumbnail size and location
    
    UIImageView *enlargedView = (UIImageView *)gesture.view;
    // get pointer to the tableView that this cell belongs to
    UITableView *guideTableView = nil;
    UIView *superView = self.superview;
    while (nil != self.superview && nil == guideTableView) {
        if ([superView isKindOfClass:[UITableView class]]) {
            guideTableView = (UITableView *)superView;
        } else {
            superView = superView.superview;
        }
    }
    
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         if (weakSelf.unzoomedCellImageView) {
                             enlargedView.bounds = weakSelf.unzoomedCellImageView.bounds;
                             enlargedView.center = weakSelf.unzoomedCellImageView.center;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             // reenable tap gesture for the tableCellImageView
                             weakSelf.unzoomedCellImageView.userInteractionEnabled = YES;
                             // cleanup
                             enlargedView.image = nil;
                             [enlargedView removeFromSuperview];
                             guideTableView.scrollEnabled = YES;
                         }
                     }];
}

#pragma mark Initializers

-(PFImageView *)unzoomedCellImageView {
    if (!_unzoomedCellImageView) {
        _unzoomedCellImageView = [[PFImageView alloc] init];
    }
    return _unzoomedCellImageView;
}

@end
