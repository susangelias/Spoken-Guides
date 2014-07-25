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

@interface InitialViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Spoken Guides";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

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

@end
