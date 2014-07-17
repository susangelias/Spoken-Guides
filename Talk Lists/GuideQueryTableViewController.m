//
//  GuideQueryTableViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 7/13/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideQueryTableViewController.h"
#import "PFStep.h"



@implementation GuideQueryTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Class name to query on
        self.parseClassName = @"PFStep";
        
        // The key of the PFObject to display  the labelofthe default cell style
        self.textKey = @"instruction";
        self.imageKey = @"thumbnail";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 8;
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self loadObjects];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    self.guide.rankedStepsInGuide = [self.objects mutableCopy];
    
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
    
    // get app's customTint color
    UIColor *customColor = [UIColor blackColor];
    [self setTextColor:customColor atIndexPath:selectedIndexPath];
}

-(void)setTextColor:(UIColor *)highlightColor atIndexPath:(NSIndexPath *)lineNumber
{
    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:lineNumber];
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
