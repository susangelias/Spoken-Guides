//
//  GuideDetailViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideDetailViewController.h"
#import "BlurryModalSegue.h"
#import "stepCell.h"
#import "Step.h"
#import "ArrayDataSource.h"
#import "ArrayDataSourceDelegate.h"

@interface GuideDetailViewController () <ArrayDataSourceDelegate, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *guideTableView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) ArrayDataSource *guideDetailVCDataSource;
@property (weak, nonatomic) IBOutlet UIImageView *guideTitleImage;
@end

@implementation GuideDetailViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.guideTableView.dataSource = self.guideDetailVCDataSource;
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
    
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
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

-(GuideContents *)guide
{
    if (!_guide) {
        _guide = [[GuideContents alloc] init];
    }
    return _guide;
}

-(ArrayDataSource *)guideDetailVCDataSource
{
    if (!_guideDetailVCDataSource) {
        // get the guide steps from our working copy of the new guide in progress
        
        
        // set up the block that will fill each tableViewCell
        void (^configureCell)(stepCell *, id) = ^(stepCell *cell, Step *guideStep) {
            [cell configureStepCell:guideStep];
        };
        
        _guideDetailVCDataSource = [[ArrayDataSource alloc] initWithItems:self.guide.steps
                                                          cellIDString:@"stepCell"
                                                    configureCellBlock:configureCell];
        _guideDetailVCDataSource.arrayDataSourceDelegate = self;
        
    }
    return _guideDetailVCDataSource;
}

@end
