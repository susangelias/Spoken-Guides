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

@property (strong, nonatomic) UIImageView *unzoomedCellImageView;
@property (nonatomic) CGPoint touchPoint;

@end

@implementation stepCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialize cell text
       // UIFont *stepCellFont = [UIFont fontWithName:kStepCellFont size:kStepCellFontSize];
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
    
    NSLog(@"STARTING text Frame width %f", self.textLabel.frame.size.width);
    if (self.imageView.file) {
        NSLog(@"have a photo");
        self.textLabel.frame = CGRectMake(15.0, 3.0, self.frame.size.width - 89.0, self.frame.size.height-0.5);
    } else {
        NSLog(@"don't have a photo");
        self.textLabel.frame = CGRectMake(15.0, 3.0, self.frame.size.width -30, self.frame.size.height-0.5);
     }
//    self.textLabel.numberOfLines = 0;

    NSLog(@"imageView.frame origin: %f,%f size: %fx%f",self.imageView.frame.origin.x, self.imageView.frame.origin.y,self.imageView.frame.size.width,self.imageView.frame.size.height);
    NSLog(@"textLabel.frame origin: %f,%f size: %fx%f",self.textLabel.frame.origin.x, self.textLabel.frame.origin.y,self.textLabel.frame.size.width,self.textLabel.frame.size.height);
    NSLog(@"contentView.frame origin: %f,%f size: %fx%f",self.contentView.frame.origin.x, self.contentView.frame.origin.y,self.contentView.frame.size.width,self.contentView.frame.size.height);
    
}

-(void)configureStepCell: (PFStep *)stepToDisplay
{
    UITapGestureRecognizer *tapped;

    if (stepToDisplay.instruction) {
        self.textLabel.text = [NSString stringWithString:stepToDisplay.instruction];
    }

  //  if (stepToDisplay.photo.thumbnail) {
    if (stepToDisplay.image) {
        // Set the thumbnail as the displayed image for now but better resolution image will get swapped in in the completion block
        /*
        [stepToDisplay getThumbnailInBackgroundWithBlock:^(UIImage *retrieveImage) {
            self.imageView.image = retrieveImage;
        }];
         */
        self.imageView.file = stepToDisplay.thumbnail;
        self.imageView.image = [UIImage imageNamed:@"image.png"];
      //  self.imageView.image = [UIImage imageWithData:stepToDisplay.photo.thumbnail];

        // Retrieve the photo so it can be displayed in the delegate method - this puts an image suitable
        // for full screen display into our thumbnail shown in the table view so when the user taps it
        // and it expands to full screen it will not be blurry as it is if I use the thumbnail here
        /*
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        __weak typeof(self)weakSelf = self;
        [library getImageForAssetURL:[NSURL URLWithString:stepToDisplay.photo.assetLibraryURL]
                 withCompletionBlock:^(UIImage *image, NSError *error) {
                     weakSelf.imageView.image = [image resizeToSquareImage];
        }];
         */

    // Add Gesture Recognizer
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
    // get pointer to the tableView that this cell belongs to
    UITableView *guideTableView = nil;
    guideTableView = (UITableView *)[self.superview findSuperViewWithClass:[UITableView class]];
    
    // get pointer to the view that the tableView belongs to
    UIView *myView = nil;
    myView = guideTableView.superview;
    
    // disable scrolling of the tableview so that can zoom photo back easily
    guideTableView.scrollEnabled = NO;
    
    // save info about our cell Image starting size and location
    self.unzoomedCellImageView = (UIImageView *)[gesture view];
    self.touchPoint = [gesture locationOfTouch:0 inView:nil];   // location of touch within the window
    // disable user interaction on the cell ImageView for now
    self.unzoomedCellImageView.userInteractionEnabled = NO;
    
    // create a new image view based on the size and location of the cell view
    CGRect adjustedFrame = self.unzoomedCellImageView.frame;
    adjustedFrame.origin.y = self.touchPoint.y;
    __block UIImageView *viewToEnlarge = [[UIImageView alloc]initWithFrame:adjustedFrame];
    __weak typeof (self) weakSelf = self;
    
    viewToEnlarge.image = self.unzoomedCellImageView.image;
    [myView addSubview:viewToEnlarge];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         viewToEnlarge.center = myView.center;
                         viewToEnlarge.bounds = guideTableView.bounds;
                         // reduce alpha of background view
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
    UIImageView *enlargedView = (UIImageView *)gesture.view;
    UITableView *guideTableView = nil;
    guideTableView = (UITableView *)[self.superview findSuperViewWithClass:[UITableView class]];
    
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         if (self.unzoomedCellImageView) {
                             enlargedView.bounds = self.unzoomedCellImageView.bounds;
                             enlargedView.center = self.touchPoint;
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


@end
