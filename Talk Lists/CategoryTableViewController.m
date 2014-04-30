//
//  CategoryTableViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/21/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "GuideDetailViewController.h"
#import "ArrayDataSource.h"

@interface CategoryTableViewController ()

@property (strong, nonatomic) NSMutableArray *dummyGuides;
@property (strong, nonatomic) ArrayDataSource *guideListDataSource;

@end

@implementation CategoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(ArrayDataSource *)guideListDataSource
{
    if (!_guideListDataSource) {
        
        void (^configureCell)(UITableViewCell *, NSString *) = ^(UITableViewCell *cell, NSString *guideTitle) {
            cell.textLabel.text = guideTitle; };
            
        self.dummyGuides = [@[@"Whatever Guide", @"Making Breakfast Guide", @"Awesome Guide", @"Short Guide"] mutableCopy];

        _guideListDataSource = [[ArrayDataSource alloc] initWithItems:self.dummyGuides
                                                         cellIDString:@"CategoryItem"
                                                                block:configureCell];
    }
    return _guideListDataSource;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.tableView.dataSource = self.guideListDataSource;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"GuideDetailSegue"]) {
        GuideDetailViewController *destVC = [segue destinationViewController];
        if ([sender isKindOfClass:[UITableViewCell class]])
        {
            UITableViewCell *senderCell = sender;
            destVC.guideTitle = senderCell.textLabel.text;

        }
    }
        
}


@end
