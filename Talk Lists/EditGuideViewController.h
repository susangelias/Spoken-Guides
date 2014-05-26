//
//  EditGuideViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 5/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Guide+Addendums.h"

@interface EditGuideViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Guide *guideToEdit;

@end
