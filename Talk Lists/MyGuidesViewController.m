//
//  MyGuidesViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 5/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "MyGuidesViewController.h"
#import "EditGuideViewController.h"
#import "GuideDetailViewController.h"
#import "ArrayDataSource.h"
#import "GuideCategories.h"
#import "fetchedResultsDataSource.h"
#import "Guide+Addendums.h"
#import "Photo+Addendums.h"
#import "ShareController.h"
#import "PFGuide.h"


@interface MyGuidesViewController ()// <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myGuidesTableView;
//@property (strong, nonatomic) fetchedResultsDataSource *guideFetchResultsController;
@property (strong, nonatomic) NSManagedObjectModel *mom;
@property (strong, nonatomic) NSURL *storeURL;
@property (weak, nonatomic) IBOutlet UIButton *createNewGuideButton;

@end

@implementation MyGuidesViewController

#pragma mark view life cycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Class name to query on
        self.parseClassName = @"PFGuide";
        
        // The key of the PFObject to display  the labelofthe default cell style
        self.textKey = @"title";
  
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 8;
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // Set up managed object context
    [self setupManagedObjectContext];
    
    // Set up the undo manager
    if (self.managedObjectContext) {
        self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
    }
 /*
    NSError *error;
    [self.guideFetchResultsController performFetch:&error];
    if (error) {
        NSLog(@"Error fetching guides for a specific category: %@", error);
    }
   self.myGuidesTableView.dataSource = self.guideFetchResultsController;
  */
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.createNewGuideButton.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.createNewGuideButton.frame.size.height;
    self.createNewGuideButton.frame = frame;
    
    [self.view bringSubviewToFront:self.createNewGuideButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [super loadObjects];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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


#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}


// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"modifiedDate"];
    
    return query;
}


// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"myGuideCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    if ([object isKindOfClass:[PFGuide class]]) {
        PFGuide *guideToDisplay = (PFGuide *)object;
        cell.textLabel.text = guideToDisplay.title;
        //cell.imageView.image = [UIImage imageWithData:fetchedGuide.photo.thumbnail];
    }
    return cell;
}


/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
 return [objects objectAtIndex:indexPath.row];
 }
 */

/*
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
            if ([anObject isKindOfClass:[Guide class]]) {
                // delete object from backend
                Guide *deletedGuide = (Guide *)anObject;
                ShareController *shareControl = [[ShareController alloc]init];
                [shareControl deleteGuide:deletedGuide];
            }
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
*/
#pragma mark User Actions

- (IBAction)EditButtonPressed:(UIBarButtonItem *)sender {
   // [self.myGuidesTableView setEditing:YES
   //                   animated:YES];
    [self.tableView setEditing:YES
                      animated:YES];
    sender.title = @"Done";
    sender.action = @selector(DoneButtonPressed:);
    
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

-(IBAction)DoneButtonPressed:(UIBarButtonItem *)sender
{
 //   [self.myGuidesTableView setEditing:NO
 //                     animated:YES];
    [self.tableView setEditing:NO
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

#pragma mark - Table view data source


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
         PFGuide *guideToDelete = (PFGuide *)[self.objects objectAtIndex:indexPath.row];
         [guideToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             if (succeeded) {
                 // Delete row from tableview
                 [self loadObjects];
              }
         }];
      }
     else if (editingStyle == UITableViewCellEditingStyleInsert) {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
 }



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewGuideSegue"] )
    {
        if ([[segue destinationViewController] isKindOfClass:[EditGuideViewController class]]) {
            EditGuideViewController *destController = (EditGuideViewController *)[segue destinationViewController];
            destController.managedObjectContext = self.managedObjectContext;
            destController.guideToEdit = nil;
            destController.steps = nil;
        }
    }
    // Pass the selected object to the edit view controller.
    else if ([segue.identifier isEqualToString:@"GuideDetailSegue"]) {
        if ([[segue destinationViewController ] isKindOfClass:[GuideDetailViewController class]]) {
            GuideDetailViewController *destVC = (GuideDetailViewController *)[segue destinationViewController ];
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            destVC.guide = (PFGuide *)[self.objects objectAtIndex:indexPath.row];
            }
        }
}

#pragma mark Initializations

-(void)setupManagedObjectContext
{
    self.managedObjectContext =
    [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator =
    [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel: self.mom];
    NSError *error;
    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:self.storeURL
                                                            options:nil
                                                              error:&error];
    if (error) {
        NSLog(@"error:  %@", error);
    }
    self.managedObjectContext.undoManager = nil;     // set to nil until such time as undo Manager is needed
}

-(NSManagedObjectModel *)mom
{
    if (!_mom) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GuideModel" withExtension:@"momd"];
        _mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _mom;
}

-(NSURL *)storeURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    if (!_storeURL) {
        _storeURL = [NSURL fileURLWithPath:[basePath stringByAppendingFormat:@"/Talk Lists.sqlite"]];
    }
    return  _storeURL;
}
/*

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
*/
@end
