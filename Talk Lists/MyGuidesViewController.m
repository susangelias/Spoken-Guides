//
//  MyGuidesViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 5/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "MyGuidesViewController.h"
#import "NewGuideViewController.h"

@interface MyGuidesViewController ()

@end

@implementation MyGuidesViewController

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
        if ([[segue destinationViewController] isKindOfClass:[NewGuideViewController class]]) {
            NewGuideViewController *destController = [segue destinationViewController];
            destController.managedObjectContext = self.managedObjectContext;
        }
    }
}


@end
