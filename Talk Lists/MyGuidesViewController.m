//
//  MyGuidesViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 5/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "MyGuidesViewController.h"
#import "EditGuideViewController.h"
#import "ArrayDataSource.h"
#import "GuideCategories.h"
#import "fetchedResultsDataSource.h"
#import "Guide+Addendums.h"
#import "Photo+Addendums.h"


@interface MyGuidesViewController () <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myGuidesTableView;
@property (strong, nonatomic) fetchedResultsDataSource *guideFetchResultsController;

@end

@implementation MyGuidesViewController

#pragma mark view life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    self.myGuidesTableView.dataSource = self.guideFetchResultsController;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
}

#pragma mark NSFetchedResultsController delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.myGuidesTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.myGuidesTableView;
    
    switch(type) {
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.myGuidesTableView endUpdates];
}

#pragma mark User Actions

- (IBAction)EditButtonPressed:(UIBarButtonItem *)sender {
    [self.myGuidesTableView setEditing:YES
                      animated:YES];
    sender.title = @"Done";
    sender.action = @selector(DoneButtonPressed:);
    
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

-(IBAction)DoneButtonPressed:(UIBarButtonItem *)sender
{
    [self.myGuidesTableView setEditing:NO
                      animated:YES];
    sender.title = @"Edit";
    sender.action = @selector(EditButtonPressed:);
    
    [self.managedObjectContext.undoManager endUndoGrouping];
    // save any changes to core data
    [self.managedObjectContext performBlock:^{
        NSError *error;
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"ERROR saving context: %@", error);
        }
    }];
    // break any retain cycles between the managed objects before leaving this view controller
    __weak typeof (self) weakSelf = self;
    [self.managedObjectContext performBlock:^{
        for (NSManagedObject *mo in weakSelf.managedObjectContext.registeredObjects) {
            [weakSelf.managedObjectContext refreshObject:mo mergeChanges:NO];
        }
    }];
    [self.managedObjectContext.undoManager removeAllActions];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewGuideSegue"] )
    {
        if ([[segue destinationViewController] isKindOfClass:[EditGuideViewController class]]) {
            EditGuideViewController *destController = [segue destinationViewController];
            destController.managedObjectContext = self.managedObjectContext;
            destController.guideToEdit = nil;
        }
    }
    else if ([segue.identifier isEqualToString:@"EditGuideSegue"]) {
        if ([[segue destinationViewController] isKindOfClass:[EditGuideViewController class]]) {
            EditGuideViewController *destController = [segue destinationViewController];
            destController.managedObjectContext = self.managedObjectContext;
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
                destController.guideToEdit = (Guide *)[[self.guideFetchResultsController fetchedObjects] objectAtIndex:indexOfGuideObject];
            }
        }
    }
}

#pragma mark Initializations

-(fetchedResultsDataSource *)guideFetchResultsController
{
    if (!_guideFetchResultsController) {

        void (^configureCell)(UITableViewCell *, Guide *) = ^(UITableViewCell *cell, Guide *fetchedGuide) {
            cell.textLabel.text = fetchedGuide.title;
            cell.imageView.image = [UIImage imageWithData:fetchedGuide.photo.thumbnail];
        };


#warning will need to add a search predicate on the user ID
    //    NSString *searchString = self.guideCategory;
        NSPredicate *predicate = nil; //[NSPredicate predicateWithFormat:@"classification == %@", searchString];
        
        _guideFetchResultsController = [[fetchedResultsDataSource alloc] initWithEntity:@"Guide"
                                                               withManagedObjectContext:self.managedObjectContext
                                                                            withSortKey:@"classification"
                                                                    withCellIndentifier:@"myGuideCell"
                                                                    withSearchPredicate:predicate
                                                                     withConfigureBlock:configureCell];
    }
    _guideFetchResultsController.delegate = self;
    return _guideFetchResultsController;
}

@end
