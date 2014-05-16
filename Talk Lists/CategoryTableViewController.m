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
#import "GuideCategories.h"
#import "fetchedResultsDataSource.h"
#import "Guide+Addendums.h"

@interface CategoryTableViewController ()

@property (strong, nonatomic) fetchedResultsDataSource *guideFetchResultsController;

@end

@implementation CategoryTableViewController

#pragma mark view life cycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error;
    [self.guideFetchResultsController performFetch:&error];
    if (error) {
        NSLog(@"Error fetching guides for a specific category: %@", error);
    }
    
    self.tableView.dataSource = self.guideFetchResultsController;
}

-(void)viewWillDisappear:(BOOL)animated
{
    // save any changes to core data
    NSError *error;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"ERROR saving context: %@", error);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);

    // Dispose of any resources that can be recreated.
}


#pragma mark User Actions
- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    [self.tableView setEditing:YES
                      animated:YES];
}


#pragma mark NSFetchedResultsController delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
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
            NSUInteger indexOfGuideObject = [[self.guideFetchResultsController fetchedObjects] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                Guide *fetchedGuide = (Guide *)obj;
                if ([fetchedGuide.title isEqualToString:senderCell.textLabel.text]) {
                    *stop = YES;     // found guide matching title from the selected table cell
                    return YES;
                }
                else {
                    return NO;
                }
            }];
            destVC.guide = (Guide *)[[self.guideFetchResultsController fetchedObjects] objectAtIndex:indexOfGuideObject];
        }
    }
}

#pragma mark Initializations

-(fetchedResultsDataSource *)guideFetchResultsController
{
    if (!_guideFetchResultsController) {
        void (^configureCell)(UITableViewCell *, Guide *) = ^(UITableViewCell *cell, Guide *fetchedGuide) {
            cell.textLabel.text = fetchedGuide.title; };
        NSString *searchString = self.guideCategory;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"classification == %@", searchString];
        
        _guideFetchResultsController = [[fetchedResultsDataSource alloc] initWithEntity:@"Guide"
                                                               withManagedObjectContext:self.managedObjectContext
                                                                            withSortKey:@"classification"
                                                                    withCellIndentifier:@"CategoryItem"
                                                                    withSearchPredicate:predicate
                                                                     withConfigureBlock:configureCell];
    }
    _guideFetchResultsController.delegate = self;
    return _guideFetchResultsController;
}

@end
