//
//  GuideQueryTableViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 7/13/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideQueryTableViewController.h"
#import "SpokenGuideCache.h"
#import "TalkListAppDelegate.h"

@interface GuideQueryTableViewController()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation GuideQueryTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Class name to query on
        self.parseClassName = @"PFStep";
        
        // The key of the PFObject to display  the labelofthe default cell style
      //  self.textKey = @"instruction";
     //   self.imageKey = @"thumbnail";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 30;
        
     }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self stylePFLoadingViewTheHardWay];
    // set view background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kAppBackgroundImageName]];
    
    // set the insets for this scroll view
 //   self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 20.0, 0.0);
}

- (void)stylePFLoadingViewTheHardWay
{
   // all of this is just to remove the shadow from the 'Loading...' status label

    UIColor *labelTextColor = [UIColor grayColor];
    UIColor *labelShadowColor = nil;
    UIActivityIndicatorViewStyle activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    // go through all of the subviews until you find a PFLoadingView subclass
    for (UIView *subview in self.view.subviews)
    {
        if ([subview class] == NSClassFromString(@"PFLoadingView"))
        {
            // find the loading label and loading activity indicator inside the PFLoadingView subviews
            for (UIView *loadingViewSubview in subview.subviews) {
                if ([loadingViewSubview isKindOfClass:[UILabel class]])
                {
                    UILabel *label = (UILabel *)loadingViewSubview;
                    {
                        label.textColor = labelTextColor;
                        label.shadowColor = labelShadowColor;
                    }
                }
                
                if ([loadingViewSubview isKindOfClass:[UIActivityIndicatorView class]])
                {
                    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)loadingViewSubview;
                    activityIndicatorView.activityIndicatorViewStyle = activityIndicatorViewStyle;
                }
            }
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // sign up to receive applicationDidBecomeActive notifications so that our cache can be reloaded
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBecameActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];

}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
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
  //   NSLog(@"application became active GuideQueryTVC %@", self.objects);
    [self loadCache];     // refresh the cache
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (stepCell *)stepCellAtLineNumber:(int)lineNumber
{
    stepCell *step;
    step = (stepCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:lineNumber inSection:0]];
    return step;
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
    for (PFStep *step in self.objects ) {
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
    BOOL isSelected = [self.selectedIndexPath isEqual:indexPath];
    CGRect rect;
    
    if (isSelected) {

        PFStep *step = self.objects[indexPath.row];
        CGSize constraint;
        if (step.image) {
            constraint = CGSizeMake(kStepCellStdWidthWithImage, NSUIntegerMax);
        }
        else {
            constraint = CGSizeMake(kStepCellStdWidthNoImage, NSUIntegerMax);
        }
        UIFont *stepCellFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:stepCellFont forKey:NSFontAttributeName];
        NSAttributedString *text  = [[NSAttributedString alloc] initWithString:step.instruction attributes:attributes];
        rect = [text boundingRectWithSize:constraint
                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                    context:nil];
        float marginAdjustment = stepCellFont.pointSize + 10.0;
        float rowHeight = ceilf(rect.size.height)+ marginAdjustment;

        return MAX(rowHeight,kStepCellStdHeight);
    }
    else return kStepCellStdHeight;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"stepCell";
    
    stepCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[stepCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     }
   
    // Configure the cell
    NSDictionary *stepAttributes = [[SpokenGuideCache sharedCache] objectForKey:object.objectId];
    PFStep *stepToDisplay = [stepAttributes objectForKey:kPFStepClassKey];
    [cell configureStepCell:stepToDisplay attributes:stepAttributes];

    // check how many lines to display for this cell
    BOOL isSelected = [self.selectedIndexPath isEqual:indexPath];
    cell.textLabel.numberOfLines = isSelected?0:3;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self refreshUIForRowSelectionAtIndexPath:indexPath];
    
    // let delegate know about this action
    if ([self.parentDelegate respondsToSelector:@selector(rowSelectedAtIndex:)]) {
        [self.parentDelegate rowSelectedAtIndex:(int)indexPath.row];
    }

}

- (void)refreshUIForRowSelectionAtIndexPath:(NSIndexPath *)indexPath
{
    // if there is already a selected path, add to cell to the redraw list
    NSMutableArray *redrawList = [[NSMutableArray alloc]init];
    if ((self.selectedIndexPath) && (![self.selectedIndexPath isEqual: indexPath])) {
        // unselect row
        [redrawList addObject:self.selectedIndexPath];
    }
    // Store the selected row and add it to the redraw list
    self.selectedIndexPath = indexPath;
    [redrawList addObject:indexPath];
    
    [self.tableView reloadRowsAtIndexPaths:redrawList withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this will not get called because of the reloadRowsAtIndexPath method call didSelectRowAtIndexPath
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

- (void)setStepAccessToPublic:(BOOL)publicAccessFlag
{
    for (PFObject *stepObject in self.objects) {
        [stepObject.ACL setPublicReadAccess:publicAccessFlag];
        [stepObject saveInBackground];
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
