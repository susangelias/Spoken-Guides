//
//  voice.m
//  textToSpeech
//
//  Created by Susan Elias on 3/2/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Voice.h"


@implementation Voice


+ (Voice *)sharedInstance
{
    // Persistent instance
    static Voice *_default = nil;
    
    if (_default != nil) {
        return _default;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    // Allocates once with Grand Central Dispatch
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      _default = [[Voice alloc]init];
                  });
#endif

    return _default;
}

@synthesize pitch = _pitch;
@synthesize rate = _rate;
@synthesize volume = _volume;

- (NSNumber *)pitch
{
    if (!_pitch) {
        _pitch = [[NSNumber alloc]init];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _pitch = [defaults objectForKey:@"PITCH"];
    if (_pitch == NULL) {
        // set to factory default
        _pitch = [NSNumber numberWithFloat:PITCH_FACTORY_DEFAULT];
    }
    return _pitch;
}

- (NSNumber *)rate
{
    if (!_rate) {
        _rate = [[NSNumber alloc]init];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _rate = [defaults objectForKey:@"RATE"];
    if (_rate == NULL) {
        // set to factory default
        _rate = [NSNumber numberWithFloat:RATE_FACTORY_DEFAULT];
    }
    return _rate;
}

- (NSNumber *)volume
{
    if (!_volume) {
        _volume = [[NSNumber alloc]init];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _volume = [defaults objectForKey:@"VOLUME"];
    if (_volume == NULL) {
        // set to factory default
        _volume = [NSNumber numberWithFloat:VOLUME_FACTORY_DEFAULT];
    }
    return _volume;
}

- (void)setPitch:(NSNumber *)pitch
{
    _pitch = pitch;
    // save into userDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:pitch forKey:@"PITCH"];
}

- (void)setRate:(NSNumber *)rate
{
    _rate = rate;
    // save into userDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:rate forKey:@"RATE"];
    
}

- (void)setVolume:(NSNumber *)volume
{
    _volume = volume;
    // save into userDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:volume forKey:@"VOLUME"];
    
}

@end
