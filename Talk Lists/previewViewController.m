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

@interface previewViewController ()  <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *stepTableView;
@property (strong, nonatomic) ArrayDataSource *guideStepsDataSource;
@property (strong, nonatomic) GuideContents *guideInProgress;

@end

@implementation previewViewController

-(ArrayDataSource *)guideStepsDataSource
{
    if (!_guideStepsDataSource) {
        // get the guide steps from our working copy of the new guide in progress
        

        // set up the block that will fill each tableViewCell
        void (^configureCell)(UITableViewCell *, id) = ^(UITableViewCell *cell, Step *guideStep) {
            cell.textLabel.text = guideStep.instruction;
          //  if (guidePhoto) {
          //      cell.imageView.image = guidePhoto;
           // }
        };

        _guideStepsDataSource = [[ArrayDataSource alloc] initWithItems:[self.guideInProgress steps]
                                                          cellIDString:@"stepCell"
                                                                 block:configureCell];
        
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark User Actions

- (IBAction)editButtonPressed:(UIButton *)sender {
    self.guideStepsDataSource.rearrangingAllowed = YES;
    self.guideStepsDataSource.editingAllowed = YES;
   [self.stepTableView setEditing:YES
                          animated:YES];

}



@end
