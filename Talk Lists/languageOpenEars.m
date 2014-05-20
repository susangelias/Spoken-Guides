//
//  languageOpenEars.m
//  AudioInput
//
//  Created by Susan Elias on 3/10/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "languageOpenEars.h"

#define kLANGUAGE_MODEL_WEIGHT 0.75

@implementation languageOpenEars

NSString * const gREPEAT_COMMAND_KEY = @"repeatCommands";
NSString * const gPROCEED_COMMAND_KEY = @"proceedCommands";
NSString * const gGO_BACK_COMMAND_KEY = @"goBackCommands";

- (NSString *)acousticModelPath
{
    if (!_acousticModelPath) {
        _acousticModelPath = [AcousticModel pathToModel:@"AcousticModelEnglish"];
    }
    return _acousticModelPath;
}

-(NSDictionary *)commands
{
    if (!_commands) {
        _commands = [[NSDictionary alloc]initWithObjectsAndKeys: @[@"NEXT"], gPROCEED_COMMAND_KEY,
                                                                 @[@"REPEAT"], gREPEAT_COMMAND_KEY,
                                                                 @[@"GOBACK"], gGO_BACK_COMMAND_KEY, nil];
    }
    return _commands;
}

- (LanguageModelGenerator *)lmGenerator
{
    if (!_lmGenerator) {
        _lmGenerator = [[LanguageModelGenerator alloc]init];
    }

    
    // Create the language model
    NSArray *commandArrays = [NSArray arrayWithArray:[self.commands allValues]];
    NSMutableArray *spokenWordsToRecognize = [[NSMutableArray alloc] init];
    [commandArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *commandArray = obj;
       [commandArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           NSString *command = obj;
           [spokenWordsToRecognize addObject:command];
       }];
    }];
    NSString *name = @"guideLanguage";
    
    NSError *err = [_lmGenerator generateRejectingLanguageModelFromArray:spokenWordsToRecognize
                                                          withFilesNamed:name
                                                  withOptionalExclusions:nil
                                                         usingVowelsOnly:FALSE
                                                              withWeight:[NSNumber numberWithFloat:kLANGUAGE_MODEL_WEIGHT]
                                                  forAcousticModelAtPath:self.acousticModelPath];
    if([err code] != noErr) {
        NSLog(@"language generator %@", err);
    }
    [ _lmGenerator deliverRejectedSpeechInHypotheses:true];
    
    NSDictionary *languageGeneratorResults = nil;
    

	
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
		
        self.lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        self.dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }

    return _lmGenerator;
}



+ (NSString *)makePronounciationCorrections:(NSString *)originalText
{
    // Check for any text substitutions - THIS SHOULD BE IN THE MODEL
    NSDictionary *textSubstitutions = @{
                                    @"one eighth": @"1/8",
                                    @"one quarter": @"1/4",
                                    @"one third": @"1/3",
                                    @"one half": @"1/2",
                                    @"two thirds": @"2/3",
                                    @"three quarters": @"3/4",
                                    @"seven eigths": @"7/8",
                                    };
        __block NSMutableString *substitutedText = [originalText mutableCopy];
        [textSubstitutions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *badlyPronounced = obj;
        NSString *wellPronounced = key;
        substitutedText = [[substitutedText stringByReplacingOccurrencesOfString:badlyPronounced withString:wellPronounced]mutableCopy];
    }];
    return [substitutedText copy];
}

@end
