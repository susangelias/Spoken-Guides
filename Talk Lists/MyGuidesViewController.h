//
//  MyGuidesViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 5/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

//@interface MyGuidesViewController : UIViewController
@interface MyGuidesViewController : PFQueryTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
