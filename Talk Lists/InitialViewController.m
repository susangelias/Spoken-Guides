//
//  InitialViewViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 7/25/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "InitialViewController.h"
#import "EditGuideViewController.h"
#import "MyGuidesViewController.h"
#import "MyAccountViewController.h"
#import "GuideCategories.h"

@interface InitialViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoryFilterButton;

@end

@implementation InitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
 
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Spoken Guides";
   
    // Replace titleView
    CGRect headerTitleSubtitleFrame = CGRectMake(0, 0, 200, 44);
    UIView* _headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
    _headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
    _headerTitleSubtitleView.autoresizesSubviews = YES;
    
    CGRect titleFrame = CGRectMake(0, 2, 200, 24);
    UILabel *titleView = [[UILabel alloc] initWithFrame:titleFrame];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor blackColor];
    //  titleView.shadowColor = [UIColor darkGrayColor];
    // titleView.shadowOffset = CGSizeMake(0, -1);
    titleView.text = @"";
    titleView.adjustsFontSizeToFitWidth = YES;
    [_headerTitleSubtitleView addSubview:titleView];
    
    CGRect subtitleFrame = CGRectMake(0, 24, 200, 44-24);
    UILabel *subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
    subtitleView.backgroundColor = [UIColor clearColor];
    subtitleView.font = [UIFont boldSystemFontOfSize:13];
    subtitleView.textAlignment = NSTextAlignmentCenter;
    subtitleView.textColor = [UIColor blackColor];
    //  subtitleView.shadowColor = [UIColor darkGrayColor];
    //   subtitleView.shadowOffset = CGSizeMake(0, -1);
    subtitleView.text = @"";
    subtitleView.adjustsFontSizeToFitWidth = YES;
    [_headerTitleSubtitleView addSubview:subtitleView];
    
    _headerTitleSubtitleView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin);
    self.navigationItem.titleView = _headerTitleSubtitleView;
    
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    MyGuidesViewController *childVC = [self.childViewControllers firstObject];
    [self setHeaderTitle:@"Spoken Guides" andSubtitle:childVC.categoryFilter];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Action

- (IBAction)filterValueChanged:(UISegmentedControl *)sender {
    if ([[self.childViewControllers firstObject] respondsToSelector:@selector(changeQueryFilter:)] )
    {
        [[self.childViewControllers firstObject] changeQueryFilter:sender.selectedSegmentIndex];
    }
}



- (IBAction)categoryButtonPressed:(UIBarButtonItem *)sender {
    // Create and show action sheet for user to filter the guides shown
    GuideCategories *catagories = [[GuideCategories alloc] init];
    UIActionSheet *filterSheet = [[UIActionSheet alloc] initWithTitle:@"Filter Guides By:"
                                                             delegate:[self.childViewControllers firstObject]
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    [catagories.categoryKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *catKeyString = (NSString *)obj;
        [filterSheet addButtonWithTitle:catKeyString];
    }];
    [filterSheet addButtonWithTitle:@"ALL"];
    [filterSheet addButtonWithTitle:@"Cancel"];
    [filterSheet showInView:self.view ];

}

#pragma mark View

-(void) setHeaderTitle:(NSString*)headerTitle andSubtitle:(NSString*)headerSubtitle {
    UIView* headerTitleSubtitleView = self.navigationItem.titleView;
    
    if (headerTitle) {
        UILabel* titleView = [headerTitleSubtitleView.subviews objectAtIndex:0];
        titleView.text = headerTitle;
    }
    if (headerSubtitle) {
        UILabel* subtitleView = [headerTitleSubtitleView.subviews objectAtIndex:1];
        subtitleView.text = headerSubtitle;
    }
}


#pragma mark - Navigation

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL performSegue = YES;
    
    if ([identifier isEqualToString:@"NewGuideSegue"] )
    {
        PFUser *currentUser = [PFUser currentUser];
        if ([PFAnonymousUtils isLinkedWithUser:currentUser]) {
            // user needs to sign up or log in before creating a new guide
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log in required"
                                                            message:@"To create a guide you first need to log in"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Log in", nil];
            [alert show];
            
            performSegue  =  NO;
        }
    }
    else {
        performSegue = YES;
    }
    return performSegue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"NewGuideSegue"] )
     {
         if ([[segue destinationViewController] isKindOfClass:[EditGuideViewController class]]) {
             EditGuideViewController *destController = (EditGuideViewController *)[segue destinationViewController];
             destController.guideToEdit = nil;
             if ([[self.childViewControllers firstObject] isKindOfClass:[MyGuidesViewController class]]) {
                 destController.editGuideDelegate = [self.childViewControllers firstObject];
             }
         }
     }
 }

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // user wants to sign up
        // Create the sign up view controller
        MyAccountViewController *logInViewController = [[MyAccountViewController alloc]init];
        [self presentViewController:logInViewController animated:YES completion:nil];
       
    }
}

@end
