//
//  TalkListAppDelegate.m
//  Talk Lists
//
//  Created by Susan Elias on 4/21/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "TalkListAppDelegate.h"
#import <Parse/Parse.h>
#import "PFGuide.h"

@implementation TalkListAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [PFGuide registerSubclass];
    [Parse setApplicationId:@"XS8vaAZaunsYpf2lyR1NNnCCPtkVd9WdqJRWAdVJ"
                  clientKey:@"pOjGQWVowyN0orIiqF74r7LQO5rPLvHv4oDAXqDr"];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"APPLICATE WILL RESIGN ACTIVE");
    [self killListeningController];
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
    [self listener];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Listening Controller

// Need to allocate and initialize listener here because it takes several seconds, otherwise user
// could see delay in reponse after 1st line read
-(ListeningController *)listener
{
    if (!_listener) {
        // Check microphone permissions
        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (!granted) {
                    // Let the user know that they need to turn on the microphone in the system settings
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                                                    message:@"Talk Notes uses the microphone for voice recognition.  To use this feature you must allow microphone access in Settings > Privacy > Microphone"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        
        _listener = [[ListeningController alloc] init];
        if (_listener) {
            [_listener startListening];  // start the calibration
        }
        
    }
    return _listener;
}


- (void)killListeningController
{
    if (self.listener) {
        if ([self.listener isListening]) {
            [self.listener stopListening];
        }
        self.listener = nil;
    }
}

@end
