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
     self.currentDataEntryVC = (DataEntryViewController *) segue.destinationViewController;
     self.currentDataEntryVC.entryText = self.entryText;
     self.currentDataEntryVC.entryImage = self.entryImage;
     self.currentDataEntryVC.entryNumber = self.entryNumber;
     self.currentDataEntryVC.dataEntryDelegate = self.dataEntryDelegate;
     
     if ([segue.identifier isEqualToString:SegueIdentifierFirst])
     {
         if (self.childViewControllers.count > 0) {
             [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.currentDataEntryVC];
         }
         else {
             [self addChildViewController:self.currentDataEntryVC];
             ((UIViewController *)self.currentDataEntryVC).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
             [self.view addSubview:((UIViewController *)self.currentDataEntryVC).view];
             [self.currentDataEntryVC didMoveToParentViewController:self];
         }
     }
     else if ([segue.identifier isEqualToString:SegueIdentifierSecond])
     {
         [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.currentDataEntryVC];
     }
 }
 
 - (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
 {
     toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
 
     [fromViewController willMoveToParentViewController:nil];
     [self addChildViewController:toViewController];
     
     CGFloat width = self.view.frame.size.width;
     CGFloat height = self.view.frame.size.height;
     
     if (self.entryTransistionDirection == Left) {
         toViewController.view.frame = CGRectMake(width, 0, width, height);
     }
     else {
         toViewController.view.frame = CGRectMake(0 - width, 0, width, height);
     }
     
     __weak typeof(self) weakSelf = self;
     [self transitionFromViewController:fromViewController
                       toViewController:toViewController
                               duration:0.4
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 if (self.entryTransistionDirection == Left) {
                                     fromViewController.view.frame = CGRectMake(0 - width, 0, width, height);
                                 }
                                 else {
                                     fromViewController.view.frame = CGRectMake(0 + width, 0, width, height);
                                 }
                                 toViewController.view.frame = CGRectMake(0, 0, width, height);
                             } 
                             completion:^(BOOL finished){
                                 [fromViewController removeFromParentViewController];
                                 [toViewController didMoveToParentViewController:weakSelf];
                             }
      ];

 }
 
- (void)swapViewControllers
 {
     self.currentSegueIdentifier = ([self.currentSegueIdentifier  isEqual: SegueIdentifierFirst]) ? SegueIdentifierSecond : SegueIdentifierFirst;
     [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
 }
 


@end
