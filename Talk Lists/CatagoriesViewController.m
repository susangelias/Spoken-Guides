//
//  CatagoryViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/21/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "CatagoriesViewController.h"
#import "CategoryTableViewController.h"
#import "GuideCategories.h"

@interface CatagoriesViewController ()
@property (weak, nonatomic) IBOutlet UIButton *generalButton;
@property (strong, nonatomic) UISegmentedControl *LocalAllSegmentControl;

@end

#warning The images/buttons here are too big - need to convert image/button to single image and assign image to the button.  Must be correctly sized, i.e. not too big

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.titleView = self.LocalAllSegmentControl;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"didReceiveMemoryWarning: %s ", __PRETTY_FUNCTION__ );
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue destinationViewController] isKindOfClass:[CategoryTableViewController  class]]) {
        CategoryTableViewController *dvc = [segue destinationViewController];
        if ([sender isKindOfClass:[UIButton class]]) {
            UIButton *pressedButton = sender;
            dvc.guideCategory = [NSString stringWithString:pressedButton.titleLabel.text];
            dvc.title = [NSString stringWithString:pressedButton.titleLabel.text];
            dvc.managedObjectContext = self.managedObjectContext;
            if (self.LocalAllSegmentControl.selectedSegmentIndex == 0) {
                // 0 = All
                dvc.myGuidesOnly = NO;
            }
            else {  // 1 = Mine
                dvc.myGuidesOnly = YES;
            }
        }
    }
}

#pragma mark initializers

- (UISegmentedControl *)LocalAllSegmentControl
{
    if (!_LocalAllSegmentControl) {
        _LocalAllSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Mine" ]];
        NSInteger selectedIndex = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.griffoem.talkList.guideScope"] integerValue];
        if (!selectedIndex) {
            selectedIndex = 0;
        }
        _LocalAllSegmentControl.selectedSegmentIndex = selectedIndex;
    }
    return _LocalAllSegmentControl;
}


@end
