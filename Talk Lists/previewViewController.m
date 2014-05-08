//
//  previewTableViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/27/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "previewViewController.h"
#import "ArrayDataSource.h"
#import "Step.h"
#import "ArrayDataSourceDelegate.h"
#import "stepCell.h"
#import "Photo+Addendums.h"

@interface previewViewController ()  <UITableViewDelegate, ArrayDataSourceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *stepTableView;
@property (strong, nonatomic) ArrayDataSource *guideStepsDataSource;
@property (weak, nonatomic) IBOutlet UILabel *guideTitle;
@property (weak, nonatomic) IBOutlet UIImageView *guidePhoto;

@end

@implementation previewViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stepTableView.dataSource = self.guideStepsDataSource;
    self.stepTableView.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.guideTitle.text = self.guideToPreview.title;
    self.guidePhoto.image  = [UIImage imageWithData:self.guideToPreview.photo.image];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
}


#pragma mark User Actions

- (IBAction)editButtonPressed:(UIButton *)sender {
    self.guideStepsDataSource.rearrangingAllowed = YES;
    self.guideStepsDataSource.editingAllowed = YES;
   [self.stepTableView setEditing:YES
                          animated:YES];

}

#pragma mark ArrayDataSourceDelegate

-(void)deletedRowAtIndex:(NSUInteger)index
{
  //  [self.guideInProgress deleteStep:index];
}

-(void)movedRowFrom:(NSUInteger)fromIndex To:(NSUInteger) toIndex
{
  //  [self.guideInProgress moveStepFromNumber:fromIndex toNumber:toIndex];
}

#pragma mark Initializers

-(ArrayDataSource *)guideStepsDataSource
{
    if (!_guideStepsDataSource) {
        
        // set up the block that will fill each tableViewCell
        void (^configureCell)(stepCell *, id) = ^(stepCell *cell, Step *guideStep) {
            [cell configureStepCell:guideStep];
        };
        
        // get the guide steps from our working copy of the new guide in progress
        _guideStepsDataSource = [[ArrayDataSource alloc] initWithItems:[self.guideToPreview sortedSteps]
                                                          cellIDString:@"stepCell"
                                                    configureCellBlock:configureCell];
        _guideStepsDataSource.arrayDataSourceDelegate = self;
        
    }
    return _guideStepsDataSource;
}



@end
