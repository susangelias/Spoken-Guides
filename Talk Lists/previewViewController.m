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
    if (self.guideToPreview.title) {
        self.guideTitle.text = self.guideToPreview.title;
    } else if (self.titleToPreview) {
        self.guideTitle.text = self.titleToPreview;
    }
    self.guidePhoto.image  = [UIImage imageWithData:self.guideToPreview.photo.thumbnail];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.guideToPreview = nil;
    [super viewWillDisappear:animated];
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
    [self.guideToPreview deleteStepAtIndex:index+1];
}

-(void)movedRowFrom:(NSUInteger)fromIndex To:(NSUInteger) toIndex
{
    [self.guideToPreview moveStepFromNumber:fromIndex+1 toNumber:toIndex+1];
}

#pragma mark Initializers

-(ArrayDataSource *)guideStepsDataSource
{
    if (!_guideStepsDataSource) {
        
        // set up the block that will fill each tableViewCell
#warning Step object being retained
        void (^configureCell)(stepCell *, id)  = ^(stepCell *cell, Step *guideStep) {
            [cell configureStepCell:guideStep];
           //cell.textLabel.text = guideStep.instruction;   // causing retain cycle as well, weak qualifier in ArrayDataSource didn't help
            // if I comment out the configure code all together the retain cycle goes away - see stepCell.m code

        };
        
        // get the guide steps from our working copy of the new guide in progress
        NSMutableArray *previewSteps = [[self.guideToPreview sortedSteps] mutableCopy];
        // add the current inprogress step if there is one
        if (self.stepToPreview) {
            [previewSteps addObject:self.stepToPreview];
        }
        _guideStepsDataSource = [[ArrayDataSource alloc] initWithItems:previewSteps
                                                          cellIDString:@"stepCell"
                                                    configureCellBlock:configureCell];
        _guideStepsDataSource.arrayDataSourceDelegate = self;
    }
    
    return _guideStepsDataSource;
}



@end
