//
//  GuideDetailViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideDetailViewController.h"
#import "BlurryModalSegue.h"

@interface GuideDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *guideTableView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) NSMutableArray *steps;
@property (strong, nonatomic) UIImageView *unzoomedCellImageView;
@property (nonatomic) CGPoint touchPoint;
@property (weak, nonatomic) IBOutlet UIImageView *guideTitleImage;
@end

@implementation GuideDetailViewController

- (NSMutableArray *)steps
{
    // set up dummy data
    if (!_steps) {
        _steps = [@[@"step 1 instructions", @"step 2 instructions", @"step 3 instructions", @"step 4 instructions", @"step 5 instructions"]mutableCopy];;
    }
    return _steps;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.guideTableView.dataSource = self;
    self.guideTableView.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.title = self.guideTitle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.steps count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stepCell" forIndexPath:indexPath];
    UITapGestureRecognizer *tapped;
    
    // Configure the cell...
    cell.textLabel.text = self.steps[indexPath.row];
    if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"general"];
        
        // Add Gesture Recognizer
        tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellImageTapped:)];
        tapped.numberOfTapsRequired = 1;
        [cell.imageView addGestureRecognizer:tapped];
        cell.imageView.userInteractionEnabled = YES;
    }
    else if (indexPath.row == 4) {
        cell.imageView.image = [UIImage imageNamed:@"Paintbrush"];
        
        // Add Gesture Recognizer
        tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellImageTapped:)];
        tapped.numberOfTapsRequired = 1;
        [cell.imageView addGestureRecognizer:tapped];
        cell.imageView.userInteractionEnabled = YES;
    }
    else {
        cell.imageView.image = nil;
        [cell.imageView removeGestureRecognizer:tapped];
    }
    return cell;
}

#pragma mark cell image enlargement management

- (void)cellImageTapped:(UITapGestureRecognizer *)gesture
{
    // disable scrolling of the tableview so that can zoom photo back easily
    self.guideTableView.scrollEnabled = NO;
    
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
    [self.view addSubview:viewToEnlarge];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         viewToEnlarge.center = self.view.center;
                         viewToEnlarge.bounds = self.guideTableView.bounds;
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
                             self.guideTableView.scrollEnabled = YES;
                       }
                     }];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row selected");
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue isKindOfClass:[BlurryModalSegue class]])
    {
        BlurryModalSegue* bms = (BlurryModalSegue*)segue;
        
        bms.backingImageBlurRadius = @(20);
        bms.backingImageSaturationDeltaFactor = @(.45);
        bms.backingImageTintColor = [[UIColor greenColor] colorWithAlphaComponent:.1];
    }
}

#pragma mark initializers

- (NSString *)guideTitle
{
    if (! _guideTitle) {
        _guideTitle = [[NSString alloc] init];
    }
    return _guideTitle;
}
@end
