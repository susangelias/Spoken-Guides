//
//  stepCell.m
//  Talk Lists
//
//  Created by Susan Elias on 5/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "stepCell.h"
#import "UIView+SuperView.h"

@interface stepCell()

@property (strong, nonatomic) UIImageView *unzoomedCellImageView;
@property (nonatomic) CGPoint touchPoint;

@end

@implementation stepCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
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

-(void)configureStepCell: (StepClassic *)step
{
    UITapGestureRecognizer *tapped;
 
    self.textLabel.text = step.instruction;
    if (step.photo) {
        self.imageView.image = step.photo;
        
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
                             UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enlargedImageTapped:)];
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
                             self.unzoomedCellImageView.userInteractionEnabled = YES;
                             // cleanup
                             enlargedView.image = nil;
                             [enlargedView removeFromSuperview];
                             guideTableView.scrollEnabled = YES;
                         }
                     }];
}

@end
