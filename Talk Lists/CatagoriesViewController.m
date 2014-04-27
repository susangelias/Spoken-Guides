//
//  CatagoryViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/21/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "CatagoriesViewController.h"
#import "CategoryTableViewController.h"

@interface CatagoriesViewController ()
@property (weak, nonatomic) IBOutlet UIButton *generalButton;

@end

@implementation CatagoriesViewController

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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue destinationViewController] isKindOfClass:[CategoryTableViewController  class]]) {
        CategoryTableViewController *dvc = [segue destinationViewController];
        NSLog(@"sender %@", sender);
        if ([sender isKindOfClass:[UIButton class]]) {
            UIButton *pressedButton = sender;
            dvc.title = pressedButton.titleLabel.text;
        }
    }
}


@end
