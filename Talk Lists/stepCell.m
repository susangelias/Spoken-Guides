//
//  stepCell.m
//  Talk Lists
//
//  Created by Susan Elias on 5/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "stepCell.h"
#import "UIImage+Resize.h"

NSString *const kStepCellFont = @"HelveticaNeue-Thin";

@interface stepCell()

@property (strong, nonatomic) PFImageView *unzoomedCellImageView;
@property (nonatomic) BOOL imageCurrentlyEnlarged;

@end

@implementation stepCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self initializeCellText];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    // Calling initWithStyle is the only way I have found to get my stepCell to display an image
    // I'm not sure what is happening in initWithStyle that makes this happen
  //  self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stepCell"];
    [self initializeCellText];
    
    return self;
}

-(void)initializeCellText
{
    if (self) {
        // Initialize cell text
        UIFont *stepCellFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.textLabel.font = stepCellFont;
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.imageCurrentlyEnlarged = NO;
    }
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
    
    if (self.stepImageView.file) {
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
        self.stepImageView.image = latestThumbnail;
        self.stepImageView.file = nil;
    }
    else if (stepToDisplay.thumbnail) {
        self.stepImageView.image = [UIImage imageNamed:@"image.png"];
        self.stepImageView.file = [stepToDisplay objectForKey:@"thumbnail"];
        [self.stepImageView.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.stepImageView.image = [UIImage imageWithData:data];
            }
        }];
    }
    else {
        // since these cells are re-used, make sure old images are cleaned out
        self.stepImageView.image = nil;
        self.stepImageView.file = nil;
    }
    if (self.stepImageView.image) {
        // if there is a photo, get the hiRes image loaded in case the user wants to zoom the thumbnail
        self.unzoomedCellImageView.image = [stepAttributes objectForKey:kPFStepChangedImage];
        if (!self.unzoomedCellImageView.image) {
            self.unzoomedCellImageView.image = [UIImage imageNamed:@"image.png"];
            self.unzoomedCellImageView.file = [stepToDisplay objectForKey:@"image"];
        }
    }
    
    // Add Gesture Recognizer
    if (self.stepImageView.image) {
        tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellImageTapped:)];
        tapped.numberOfTapsRequired = 1;
        [self.stepImageView addGestureRecognizer:tapped];
        self.stepImageView.userInteractionEnabled = YES;
    }
    else {
        self.stepImageView.image = nil;
        [self.stepImageView removeGestureRecognizer:tapped];
    }
}


#pragma mark cell image enlargement management

- (void)cellImageTapped:(UITapGestureRecognizer *)gesture
{
    // Zooms the thumbnail photo to center screen, enlarged

    // If image is already enlarged, just return
    if (self.imageCurrentlyEnlarged == YES) {
        return;
    }
    else {
        [self enlargeImage];
    }
   
 }

-(void)enlargedImageTapped:(UITapGestureRecognizer *)gesture
{
    [self shrinkImage];
}

-(void) enlargeImage
{
    // save original location of unzoomed image
    // convert tapped image frame to superview coordinates
    if (self.stepImageView.image) {
 //       CGPoint tappedImageCenterConverted = [self.viewForBaselineLayout convertPoint:self.stepImageView.center toView:self.superview.superview];
        CGPoint tappedImageCenterConverted = [self.stepImageView convertPoint:self.stepImageView.center toView:self.superview.superview];
        self.unzoomedCellImageView.center = tappedImageCenterConverted;
        self.unzoomedCellImageView.bounds = self.stepImageView.bounds;

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
                viewToEnlarge.image = weakSelf.stepImageView.image;
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

        [viewToEnlarge setTag:100];
        [myView addSubview:viewToEnlarge];
        self.imageCurrentlyEnlarged = YES;

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
}

-(void) shrinkImage
{
    // Shrink the enlarged image back down to the thumbnail size and location
    
    //UIImageView *enlargedView = (UIImageView *)gesture.view;

    if (self.imageCurrentlyEnlarged == YES) {
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

        UIImageView *enlargedView = (UIImageView *)[myView viewWithTag:100];
        
        __weak typeof (self) weakSelf = self;
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionShowHideTransitionViews
                         animations:^{
                             if (weakSelf.unzoomedCellImageView) {
                                 enlargedView.bounds = weakSelf.unzoomedCellImageView.bounds;
                               //  NSLog(@"UnzoomedCellImageView x %f,  y %f", weakSelf.unzoomedCellImageView.center.x, weakSelf.unzoomedCellImageView.center.y);
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
                                 weakSelf.imageCurrentlyEnlarged = NO;
                             }
                         }];
    }
}

#pragma mark Initializers

-(PFImageView *)unzoomedCellImageView {
    if (!_unzoomedCellImageView) {
        _unzoomedCellImageView = [[PFImageView alloc] init];
    }
    return _unzoomedCellImageView;
}

@end
