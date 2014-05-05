//
//  previewTableViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/27/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "previewViewController.h"
#import "ArrayDataSource.h"
#import "GuideContents.h"
#import "Step.h"
#import "ArrayDataSourceDelegate.h"
#import "stepCell.h"

@interface previewViewController ()  <UITableViewDelegate, ArrayDataSourceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *stepTableView;
@property (strong, nonatomic) ArrayDataSource *guideStepsDataSource;
@property (strong, nonatomic) GuideContents *guideInProgress;

@end

@implementation previewViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stepTableView.dataSource = self.guideStepsDataSource;
    self.stepTableView.delegate = self;
    
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
    [self.guideInProgress deleteStep:index];
}

-(void)movedRowFrom:(NSUInteger)fromIndex To:(NSUInteger) toIndex
{
    [self.guideInProgress moveStepFromNumber:fromIndex toNumber:toIndex];
}

#pragma mark Initializers

-(ArrayDataSource *)guideStepsDataSource
{
    if (!_guideStepsDataSource) {
        // get the guide steps from our working copy of the new guide in progress
        
        
        // set up the block that will fill each tableViewCell
        void (^configureCell)(stepCell *, id) = ^(stepCell *cell, Step *guideStep) {
            [cell configureStepCell:guideStep];
        };
        
        _guideStepsDataSource = [[ArrayDataSource alloc] initWithItems:self.guideInProgress.steps
                                                          cellIDString:@"stepCell"
                                                    configureCellBlock:configureCell];
        _guideStepsDataSource.arrayDataSourceDelegate = self;
        
    }
    return _guideStepsDataSource;
}

-(GuideContents *)guideInProgress
{
    if (!_guideInProgress) {
        _guideInProgress = [[GuideContents alloc]init];
    }
    return _guideInProgress;
}


@end
