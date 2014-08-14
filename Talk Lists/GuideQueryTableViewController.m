//
//  GuideQueryTableViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 7/13/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideQueryTableViewController.h"
#import "PFStep.h"
#import "SpokenGuideCache.h"
#import "TalkListAppDelegate.h"

@implementation GuideQueryTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Class name to query on
        self.parseClassName = @"PFStep";
        
        // The key of the PFObject to display  the labelofthe default cell style
   //     self.textKey = @"instruction";
   //     self.imageKey = @"thumbnail";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // sign up to receive applicationDidBecomeActive notifications so that our cache can be reloaded
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBecameActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    // set view background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kAppBackgroundImageName]];

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
     NSLog(@"application became active GuideQueryTVC %@", self.objects);
    [self loadCache];     // refresh the cache
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    self.guide.rankedStepsInGuide = [self.objects mutableCopy];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    if (!error) {
        [self loadCache];
        
        // cellForRowAtIndexPath is being called before the objects are loaded, why I don't know
        // so force it to be called again now that cache is setup
       [self.tableView reloadData];
    }

}

-(void)loadCache
{
    // remove steps for this guide then reload them
    for (PFStep *step in self.objects ) {
        //  [[SpokenGuideCache sharedCache] removeObjectForKey:step.objectId];
        [[SpokenGuideCache sharedCache] setAttributesForPFStep:step
                                                  changedImage:nil
                                              changedThumbnail:nil];
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

    if (self.guide) {
        PFRelation *relation = [self.guide relationForKey:@"pfSteps"];
        query = [relation query];
        [query orderByAscending:@"rank"];
    }
   
    return query;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
        if (![self isLoading]) {
            [self loadNextPage];
        }
    }
}

#pragma mark UITableViewDataSource

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
        // delete step from instance of model
        __weak typeof (self) weakSelf = self;
        [self.guide deleteStepAtIndex:indexPath.row withCompletionBlock:^{
            [weakSelf loadObjects];
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.guide moveStepFromNumber:fromIndexPath.row+1 toNumber:toIndexPath.row+1];
    // need to refresh the rankedSteps array so call load objects which will do this
    [self loadObjects];
    
    // turn off editing mode automatically after a row is moved
    [self.tableView setEditing:NO animated:YES];
    
    // erase the dialog controller's list of steps and let it rebuild them
  //  self.dialogController.instructions = nil;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark UITableViewDelegate
// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"guideCell";
    
    guideCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[guideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     }
   
    // Configure the cell
    NSDictionary *stepAttributes = [[SpokenGuideCache sharedCache] objectForKey:object.objectId];
    PFStep *stepToDisplay = [stepAttributes objectForKey:kPFStepClassKey];
    cell.textLabel.text = stepToDisplay.instruction;
    
    UIImage *latestThumbnail = [stepAttributes objectForKey:kPFStepChangedThumbnail];
    if (latestThumbnail) {
        cell.imageView.image = latestThumbnail;
        cell.imageView.file = nil;
    }
    else if (stepToDisplay.thumbnail) {
        cell.imageView.image = [UIImage imageNamed:@"image.png"];
        cell.imageView.file = [stepToDisplay objectForKey:@"thumbnail"];
    }
    else {
        // since these cells are re-used, make sure old images are cleaned out
        cell.imageView.image = nil;
        cell.imageView.file = nil;
    }
    
    return cell;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // unselect the row since text color will change when row is spoken
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [selectedCell setSelected:NO animated:YES ];
    
    // let delegate know about this action
    [self.parentDelegate rowSelectedAtIndex:indexPath.row];
}


#pragma mark User Actions

- (IBAction)longPressGesture:(UILongPressGestureRecognizer *)sender {
    [self.tableView setEditing:YES
                    animated:YES];
}

- (void)unhighlightCurrentLine:(int) lineNumber
{
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:lineNumber inSection:0];
    
    UIColor *customColor = [UIColor whiteColor];
    [self setTextColor:customColor atIndexPath:selectedIndexPath];
}

-(void)setTextColor:(UIColor *)highlightColor atIndexPath:(NSIndexPath *)lineNumber
{
    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:lineNumber];
    if (currentCell) {
        NSMutableAttributedString *cellAttributedText = [currentCell.textLabel.attributedText mutableCopy];
        NSDictionary *highlightedTextAttributes;
        NSRange highlightedRange;
        if (lineNumber >= 0)  {
            // HIGHLIGHT STROKE COLOR OF CURRENT LINE
            if (highlightColor) {
                highlightedTextAttributes  = @{NSForegroundColorAttributeName: highlightColor};
                highlightedRange =  NSMakeRange(0, [cellAttributedText length]);
            }
        }
        // APPLY ATTRIBUTES
        if (highlightedTextAttributes) {
            [cellAttributedText addAttributes:highlightedTextAttributes range:highlightedRange];
        }
        currentCell.textLabel.attributedText = [cellAttributedText copy];
    }
 
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

@end
