//
//  DataEntryContainerViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 7/18/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "DataEntryContainerViewController.h"

@interface DataEntryContainerViewController ()

@property (strong, nonatomic) NSString *currentSegueIdentifier;


@end

@implementation DataEntryContainerViewController

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
    // Do any additional setup after loading the view.
    self.currentSegueIdentifier = SegueIdentifierFirst;
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     DataEntryViewController *destinationDataEntryVC = (DataEntryViewController *) segue.destinationViewController;
     destinationDataEntryVC.entryText = self.entryText;
     //  destinationDataEntryVC.entryPFFile = self.entryPFFile;
     destinationDataEntryVC.entryImage = self.entryImage;
     destinationDataEntryVC.entryNumber = self.entryNumber;
     destinationDataEntryVC.dataEntryDelegate = self.dataEntryDelegate;
     
     if ([segue.identifier isEqualToString:SegueIdentifierFirst])
     {
         if (self.childViewControllers.count > 0) {
             [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:destinationDataEntryVC];
         }
         else {
             [self addChildViewController:destinationDataEntryVC];
             ((UIViewController *)destinationDataEntryVC).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
             [self.view addSubview:((UIViewController *)destinationDataEntryVC).view];
             [destinationDataEntryVC didMoveToParentViewController:self];
         }
     }
     else if ([segue.identifier isEqualToString:SegueIdentifierSecond])
     {
         [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:destinationDataEntryVC];
     }
 }
 
 - (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
 {
     toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
 
     [fromViewController willMoveToParentViewController:nil];
     [self addChildViewController:toViewController];
     [self transitionFromViewController:fromViewController toViewController:toViewController duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
         [fromViewController removeFromParentViewController];
         [toViewController didMoveToParentViewController:self];
     }];
 }
 
 - (void)swapViewControllers
 {
     self.currentSegueIdentifier = ([self.currentSegueIdentifier  isEqual: SegueIdentifierFirst]) ? SegueIdentifierSecond : SegueIdentifierFirst;
     [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
 }
 


@end