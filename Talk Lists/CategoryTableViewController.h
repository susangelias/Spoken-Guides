//
//  CategoryTableViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 4/21/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryTableViewController : UITableViewController

@property (nonatomic) BOOL myGuidesOnly;
@property (nonatomic, strong) NSString *guideCategory;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
