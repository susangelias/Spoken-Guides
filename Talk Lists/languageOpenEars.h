//
//  languageOpenEars.h
//  AudioInput
//
//  Created by Susan Elias on 3/10/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/AcousticModel.h>
#import <Rejecto/LanguageModelGenerator+Rejecto.h>

// WORDS OR PHRASES TO RECOGNIZE
extern NSString * const gREPEAT_COMMAND_KEY;
extern NSString * const gPROCEED_COMMAND_KEY;
extern NSString * const gGO_BACK_COMMAND_KEY;

@interface languageOpenEars : NSObject

@property (nonatomic, strong) LanguageModelGenerator *lmGenerator;
@property (nonatomic, strong) NSString *acousticModelPath;
@property (nonatomic, strong) NSString *lmPath;
@property (nonatomic, strong) NSString *dicPath;
@property (nonatomic, strong) NSDictionary *commands;

+ (NSString *)makePronounciationCorrections:(NSString *)originalText;

@end
