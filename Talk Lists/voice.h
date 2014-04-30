//
//  voice.h
//  textToSpeech
//
//  Created by Susan Elias on 3/2/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Voice : NSObject


#define RATE_FACTORY_DEFAULT 0.25f
#define PITCH_FACTORY_DEFAULT 1.0f
#define VOLUME_FACTORY_DEFAULT 1.0f

@property (nonatomic, strong) NSNumber *pitch;
@property (nonatomic, strong) NSNumber *rate;
@property (nonatomic, strong) NSNumber *volume;


#pragma mark Singleton

+ (Voice *) sharedInstance;

@end
