//
//  TalkListAppDelegate.m
//  Talk Lists
//
//  Created by Susan Elias on 4/21/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

NSString *const kParseApplicationKey = @"XS8vaAZaunsYpf2lyR1NNnCCPtkVd9WdqJRWAdVJ";
NSString *const kParseMasterKey = @"pOjGQWVowyN0orIiqF74r7LQO5rPLvHv4oDAXqDr";
NSString *const kAppBackgroundImageName = @"escheresque";

#import "TalkListAppDelegate.h"
#import <Parse/Parse.h>
#import "PFGuide.h"
#import "PFStep.h"

@implementation TalkListAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // set up app-wide colors

    // set the status bar to use white text
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // set up navigation bar color for entire app
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:kAppBackgroundImageName]]];
 //   [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:250.0/255 green:235.0/255 blue:215.0/255 alpha:1.0]}];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.0 alpha:1.0]}];
    
    // set the app's custom tintColor
    self.window.tintColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"AppleGreen"]];
    
    // Set up required items for Parse backend
    [PFGuide registerSubclass];
    [PFStep registerSubclass];
    
    [Parse setApplicationId:kParseApplicationKey
                  clientKey:kParseMasterKey];
    
    // check if a user is logged in already or should the anonymous user be set up
    if (![PFUser currentUser]) {
        // set up an anonymous user
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Anonymous login failed");
            }
            else {
                NSLog(@"Anonymous user logged in");
            }
        }];
    }
    
    // set default permissions on Parse objects to read- everybody, write-creator
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
 //   self.window.backgroundColor = [UIColor whiteColor];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  //  NSLog(@"APPLICATE WILL RESIGN ACTIVE");

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Allocate and start the calibration for the ListeningController - this is a singleton and the calibration takes 5 to 7 secs
    NSLog(@"APPLICATION DID BECOME ACTIVE");

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
