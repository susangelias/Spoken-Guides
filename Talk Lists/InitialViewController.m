//
//  InitialViewViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 7/25/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "InitialViewController.h"
#import "EditGuideViewController.h"
#import "AllGuidesViewController.h"
#import "MyAccountViewController.h"
#import "GuideCategories.h"
#import "TalkListAppDelegate.h"

@interface InitialViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoryFilterButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

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
    
    self.navigationItem.title = @"SPOKEN GUIDES";
    
    // set view background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kAppBackgroundImageName]];
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    

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
    UIActionSheet *filterSheet = [[UIActionSheet alloc] initWithTitle:@"Filter Guides By Catagory:"
                                                             delegate:[self.childViewControllers firstObject]
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    [catagories.categoryKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *catKeyString = (NSString *)obj;
        [filterSheet addButtonWithTitle:catKeyString];
    }];
    [filterSheet addButtonWithTitle:kALLCATAGORIES];
    [filterSheet addButtonWithTitle:@"Cancel"];
    [filterSheet showInView:self.view ];
    
}


#pragma mark - Navigation

- (IBAction) unwindToInitialViewController:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"called unwindToInitialViewController: unwind action");
}

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
             if ([[self.childViewControllers firstObject] isKindOfClass:[AllGuidesViewController class]]) {
                 destController.editGuideDelegate = [self.childViewControllers firstObject];
             }
         }
     }
 }

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // user wants to sign up
        [self performSegueWithIdentifier:@"myAccountViewSegue" sender:self];
    }
}

@end
