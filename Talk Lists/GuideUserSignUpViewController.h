//
//  GuideUserSignUpViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 7/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Parse/Parse.h>

@interface GuideUserSignUpViewController : PFSignUpViewController

@property (nonatomic, strong) PFUser *user;

@end