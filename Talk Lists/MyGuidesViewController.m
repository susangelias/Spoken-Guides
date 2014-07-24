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
#import "GuideCategories.h"
#import "PFGuide.h"
#import "guideCell.h"
#import "EditGuideViewControllerDelegate.h"
#import "SpokenGuideCache.h"


@interface MyGuidesViewController () < EditGuideViewControllerDelegate >

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
   //     self.textKey = @"title";
   //     self.imageKey = @"thumbnail";
       // self.placeholderImage = [UIImage imageNamed:@"image.png"];
  
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 20;
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
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
    [self.queryForTable clearCachedResult];
}


#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    // This method is called every time objects are loaded from Parse via the PFQuery

    // called once for cache query and once for network query
    if (!error) {
        [[SpokenGuideCache sharedCache] clear]; // CLEAR THE CACHE BEFORE RELOADING IT
        for (PFGuide *guide in self.objects ) {
            NSLog(@"LOADED guide into cache %@", guide);
            [[SpokenGuideCache sharedCache] setAttributesForPFGuide:guide
                                                       changedImage:nil
                                                   changedThumbnail:nil];
            }
    }
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
    else {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    [query orderByDescending:@"updatedAt"];
    
    return query;
}

#pragma mark UITableViewDelegate

/*
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    // get the number of guides currently in the cache
    NSArray *guides = [[SpokenGuideCache sharedCache] allObjects];
    rowCount = [guides count];
    NSLog(@"OBJECT count: %lu", (unsigned long)[self.objects count]);
    return rowCount;
}
*/

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    guideCell *customCell = (guideCell *)cell;
    customCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuideDetailViewController *destinationController = [[GuideDetailViewController alloc] init];
    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc]initWithIdentifier:@"GuideDetailSegue"
                                                                     source:self
                                                                destination:destinationController];
    [self performSegueWithIdentifier:@"GuideDetailSegue" sender:segue];
}


// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"guideCell";
    
    guideCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[guideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     }
    
    // Configure the cell
    if ([object isKindOfClass:[PFGuide class]]) {
        NSDictionary *guideAttributes = [[SpokenGuideCache sharedCache] objectForKey:object.objectId];
        PFGuide *guideToDisplay = [guideAttributes objectForKey:kPFGuideClassKey];
        cell.textLabel.text = guideToDisplay.title;
        
        UIImage *latestThumbnail = [guideAttributes objectForKey:kPFGuideChangedThumbnail];
        if (latestThumbnail) {
            cell.imageView.image = latestThumbnail;
            cell.imageView.file = nil;
        }
        else if (guideToDisplay.thumbnail) {
            cell.imageView.image = [UIImage imageNamed:@"image.png"];
            cell.imageView.file = [guideToDisplay objectForKey:@"thumbnail"];
            }
        else {
            // since these cells are re-used, make sure old images are cleaned out
            cell.imageView.image = nil;
            cell.imageView.file = nil;
        }
        }
    return cell;
}


/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
     PFObject *object = [self.objects objectAtIndex:indexPath.row];
     NSLog(@"OBJECT %@ at row %u, updatedAt %@", object, indexPath.row, object.updatedAt);
     return [self.objects objectAtIndex:indexPath.row];
 }
 */

#pragma mark User Actions

- (IBAction)EditButtonPressed:(UIBarButtonItem *)sender {
    [self.tableView setEditing:YES
                      animated:YES];
    sender.title = @"Done";
    sender.action = @selector(DoneButtonPressed:);
    
}

-(IBAction)DoneButtonPressed:(UIBarButtonItem *)sender
{
    [self.tableView setEditing:NO
                              animated:YES];
    sender.title = @"Edit";
    sender.action = @selector(EditButtonPressed:);
    
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
         PFRelation *guideSteps = guideToDelete.pfSteps;
         PFQuery *query = [guideSteps query];
         [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
             NSArray *stepsToDelete = objects;
             [stepsToDelete enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 PFStep *stepToDelete = obj;
                 [stepToDelete deleteEventually];
             }];
         }];
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

#pragma mark - EditGuideViewControllerDelegate

-(void) changedGuideUploading
{
    [self.tableView reloadData];
}

-(void) changedGuideFinishedUpload
{
    [self loadObjects];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewGuideSegue"] )
    {
        if ([[segue destinationViewController] isKindOfClass:[EditGuideViewController class]]) {
            EditGuideViewController *destController = (EditGuideViewController *)[segue destinationViewController];
            destController.guideToEdit = nil;
            destController.editGuideDelegate = self;
        }
    }
    // Pass the selected object to the edit view controller.
    else if ([segue.identifier isEqualToString:@"GuideDetailSegue"]) {
        if ([[segue destinationViewController ] isKindOfClass:[GuideDetailViewController class]]) {
            GuideDetailViewController *destVC = (GuideDetailViewController *)[segue destinationViewController ];
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            destVC.guide = (PFGuide *)[self.objects objectAtIndex:indexPath.row];
            destVC.editGuideDelegate = self;
            }
        }
}



#pragma mark Initializations

@end
