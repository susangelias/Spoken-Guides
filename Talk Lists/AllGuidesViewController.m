//
//  AllGuidesViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 5/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "AllGuidesViewController.h"
#import "EditGuideViewController.h"
#import "GuideDetailViewController.h"
#import "GuideCategories.h"
#import "PFGuide.h"
#import "guideCell.h"
#import "EditGuideViewControllerDelegate.h"
#import "SpokenGuideCache.h"
#import "InitialViewController.h"

NSInteger const kFetchLimit = 15;

@interface AllGuidesViewController () < EditGuideViewControllerDelegate, UIActionSheetDelegate >

@property (nonatomic) NSUInteger queryOrder;
@property (weak, nonatomic) IBOutlet UIButton *currentCategoryButton;
@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (nonatomic, strong) PFUser *activeUser;
@property (nonatomic, strong) NSMutableArray *guideObjects;
@property (nonatomic) NSInteger skip;

@end

@implementation AllGuidesViewController

#pragma mark view life cycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.categoryFilter = kALLCATAGORIES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.skip = 0;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // sign up to receive applicationDidBecomeActive notifications so that our cache can be reloaded
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBecameActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
     [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
}


- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadGuides:nil];
    [self.currentCategoryButton setTitle:self.categoryFilter forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
    [self.queryForTable clearCachedResult];
}

-(void)applicationBecameActive:(NSNotification *)notification
{
    [self loadCache];     // refresh the cache
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Parse

- (void)loadGuides:(NSError *)error {
    PFQuery *query = [self queryForTable];
    [self.loadingActivity startAnimating];
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [weakSelf.loadingActivity stopAnimating];
        if (!error) {
            /*
            NSMutableArray *freshObjects = [NSMutableArray arrayWithArray:objects];
            [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {                 // loop through all the freshly downloaded guides
                PFGuide *freshGuide = (PFGuide *)obj;
                [weakSelf.guideObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {   // loop through total list of guides
                    PFGuide *previousGuide = (PFGuide *) obj;
                    if ([freshGuide.objectId isEqualToString: previousGuide.objectId]) {                // refresh a found guides with the fresh download copy
                        [weakSelf.guideObjects replaceObjectAtIndex:idx withObject:freshGuide];
                        [freshObjects removeObject:freshGuide];                                         // remove the copied guide from the download list
                    }
                }];
            }];
            [weakSelf.guideObjects addObjectsFromArray:freshObjects];                                       // add any new guides that weren't already in our total list of guides
             */
            weakSelf.guideObjects = [objects mutableCopy];
            [weakSelf loadCache];
            [weakSelf.tableView reloadData];
        }
        else {
            NSLog(@"domain %@, code %d, userInfo %@", error.domain, error.code, error.userInfo);
            if  ( ([error.domain isEqualToString:@"Parse"] && (error.code == 100)) ||
                 ([error.domain isEqualToString:@"NSURLErrorDomain"] && (error.code == -1001)) )
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Unable to load guides.  Please check internet connection."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }];
}


-(void)loadCache
{
    for (PFGuide *guide in self.guideObjects ) {
        [[SpokenGuideCache sharedCache] setAttributesForPFGuide:guide
                                                   changedImage:nil
                                               changedThumbnail:nil];
    }
    //   NSLog(@"self.objects count %d", [self.objects count]);
}



// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    
    PFUser *currentUser = [PFUser currentUser];
    if (![currentUser.objectId isEqual:self.activeUser.objectId]) {
        // clear the guides downloaded
        [self.guideObjects removeAllObjects];
        self.activeUser = currentUser;
    }

    
    PFQuery *query = [PFQuery queryWithClassName:@"PFGuide"];
    
    if (self.queryOrder == 1) {
        // My Guides Only
     //   PFUser *currentUser = [PFUser currentUser];
        [query whereKey: @"user" equalTo: self.activeUser];
    }
    if ( ![self.categoryFilter isEqualToString:kALLCATAGORIES] ) {
        // limit object to a selected category
        [query whereKey:@"classification" equalTo:self.categoryFilter];
    }
    
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.guideObjects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
 //   else {
 //       query.cachePolicy = kPFCachePolicyNetworkOnly;
 //   }
    
    query.limit = kFetchLimit;
    query.skip = self.skip;
    
    [query orderByDescending:@"updatedAt"];
    
    return query;
}

#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex != actionSheet.numberOfButtons-1 ) {
        self.categoryFilter  = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self.currentCategoryButton setTitle:self.categoryFilter forState:UIControlStateNormal];
 
        [self.guideObjects removeAllObjects];
        [self loadGuides:nil];
    }
}

-(void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    
    // Change button colors from the standard blue to grey/black
    for (UIView *subView in actionSheet.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected] ;
        }
    }
}

#pragma mark All or Mine Filtering

-(void)changeQueryFilter: (NSUInteger)filterType
{
    // ALL GUIDES OR MY GUIDES ONLY
    self.queryOrder = filterType;
    
    [self.guideObjects removeAllObjects];
    [self loadGuides:nil];
}


#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    guideCell *customCell = (guideCell *)cell;
    customCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.guideObjects count] ) {
        return 78;
    }
    else {
        return 45;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.guideObjects count]) {
        GuideDetailViewController *destinationController = [[GuideDetailViewController alloc] init];
        UIStoryboardSegue *segue = [[UIStoryboardSegue alloc]initWithIdentifier:@"GuideDetailSegue"
                                                                         source:self
                                                                    destination:destinationController];
        [self performSegueWithIdentifier:@"GuideDetailSegue" sender:segue];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.guideObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"guideCell";
    
    if (indexPath.row > [self.guideObjects count]) {
        return nil;
    }
    
    guideCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[guideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    PFGuide *guideToDisplay = (PFGuide *)[self.guideObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = guideToDisplay.title;
    
    NSDictionary *guideAttributes = [[SpokenGuideCache sharedCache] objectForKey:guideToDisplay.objectId];
    UIImage *latestThumbnail = [guideAttributes objectForKey:kPFGuideChangedThumbnail];
    if (latestThumbnail) {
        // display the local copy of the thumbnail as the upload/download of the new photo hasn't finished yet
        cell.imageView.image = latestThumbnail;
        cell.imageView.file = nil;
    }
    else if (guideToDisplay.thumbnail) {
        cell.imageView.image = [UIImage imageNamed:@"image.png"];
        cell.imageView.file = [guideToDisplay objectForKey:@"thumbnail"];
        [cell.imageView.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                cell.imageView.image = [UIImage imageWithData:data];
            }
        }];
    }
    else {
        // since these cells are re-used, make sure old images are cleaned out
        cell.imageView.image = nil;
        cell.imageView.file = nil;
    }
    // refresh dynamic text
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    BOOL canEdit = NO;
    
    PFGuide *guideToEdit = (PFGuide *)[self.guideObjects objectAtIndex:indexPath.row];
    PFACL *guideACL = guideToEdit.ACL;
    if ([guideACL getWriteAccessForUser:[PFUser currentUser]]) {
        canEdit = YES;
    }
    return canEdit;
}


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

- (IBAction)categoryButtonPressed:(UIButton *)sender {
    if ([self.parentViewController isKindOfClass:[InitialViewController class]]) {
        InitialViewController *parentVC = (InitialViewController *)self.parentViewController;
        [parentVC performSelector:@selector(categoryButtonPressed:) withObject:parentVC.categoryButton];
    }
}


 - (IBAction)loadMoreButtonPressed:(UIButton *)sender {
     if  (self.loadingActivity.isAnimating == NO) {
         self.skip = [self.guideObjects count];
         [self loadGuides:nil];
     }
 
 }

- (void)refreshTable:(UIRefreshControl *)refresh {
    [self loadGuides:nil];
    [refresh endRefreshing];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak typeof(self) weakSelf = self;
        // Delete the row from the data source
        PFGuide *guideToDelete = (PFGuide *)[self.guideObjects objectAtIndex:indexPath.row];
        [self.guideObjects removeObject:guideToDelete];
        // Delete all the guide's steps first
        PFRelation *guideSteps = guideToDelete.pfSteps;
        PFQuery *query = [guideSteps query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFStep *stepToDelete in objects) {
                [stepToDelete deleteEventually];
            };
            // Now delete the guide
            [guideToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // Update the tableview
                  //  [weakSelf.tableView reloadData];
                    [weakSelf refreshTable:nil];
                }
            }];
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
    [self loadGuides:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Pass the selected object to the edit view controller.
    if ([segue.identifier isEqualToString:@"GuideDetailSegue"]) {
        if ([[segue destinationViewController ] isKindOfClass:[GuideDetailViewController class]]) {
            GuideDetailViewController *destVC = (GuideDetailViewController *)[segue destinationViewController ];
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            destVC.guide = (PFGuide *)[self.guideObjects objectAtIndex:indexPath.row];
            destVC.editGuideDelegate = self;
        }
    }
}



#pragma mark Initializations

-(NSMutableArray *)guideObjects
{
    if (!_guideObjects) {
        _guideObjects = [[NSMutableArray alloc]init];
    }
    return _guideObjects;
}

@end
