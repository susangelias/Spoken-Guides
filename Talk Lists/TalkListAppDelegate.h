//
//  TalkListAppDelegate.h
//  Talk Lists
//
//  Created by Susan Elias on 4/21/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ListeningController.h"

extern NSString *const kParseApplicationKey;
extern NSString *const kParseClientKey;
extern NSString *const kAppBackgroundImageName;

@interface TalkListAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
