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
#import "guideList.h"
#import "GuideCategories.h"

@interface CategoryTableViewController ()

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
        
        guideList *listForCategory = [[guideList alloc] init];
        // set the category for the search
        GuideCategories *guideCats = [[GuideCategories alloc]init];
        listForCategory.guideCategory = [guideCats.categories objectForKey:self.guideCategory];
        
        // set whether search is local or database
        listForCategory.local = self.myGuidesOnly;
        
        // guideList must run the search with a completion handler
        // code can't crash if there is a lag in data coming back to populate the tableview
        
        void (^configureCell)(UITableViewCell *, NSString *) = ^(UITableViewCell *cell, NSString *guideTitle) {
            cell.textLabel.text = guideTitle; };
        
        _guideListDataSource = [[ArrayDataSource alloc] initWithItems:listForCategory.guides
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
