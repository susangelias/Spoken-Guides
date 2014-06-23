//
//  ShareController.m
//  Talk Lists
//
//  Created by Susan Elias on 6/16/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "ShareController.h"
#import <Parse/Parse.h>
#import "PFGuide.h"

@implementation ShareController

-(void)shareGuide:(Guide *)CDGuide
{

    if (CDGuide == nil) {
        return;
    }
   
    __block PFGuide *guideToShare;
    
    // publish the guide
    if ([CDGuide.uniqueID hasPrefix:@"Talk Notes"]) {
        [self createGuideAndUpload:CDGuide];
    }
    else {
        // retrieve guide from backend and update
        PFQuery *query = [PFQuery queryWithClassName:@"PFGuide"];

        [query getObjectInBackgroundWithId:CDGuide.uniqueID block:^(PFObject *object, NSError *error) {
            if (!error) {
                guideToShare = (PFGuide *)object;
              //  [guideToShare initPFGuide:CDGuide];
                [guideToShare saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        CDGuide.uniqueID = guideToShare.objectId;
                    }
                    if (error) {
                        NSLog(@"error publishing guide %@", error);
                    }
                }];
                
            }
        }];
    }
    
}

-(void)createGuideAndUpload:(Guide *)CDGuide
{
    PFGuide *guideToShare = [PFGuide object];
//    [guideToShare initPFGuide:CDGuide];
    [guideToShare saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            CDGuide.uniqueID = guideToShare.objectId;
        }
        if (error) {
            NSLog(@"error publishing guide %@", error);
        }
    }];
}

-(void)deleteGuide:(Guide *)CDGuide
{
    if (![CDGuide.uniqueID hasPrefix:@"Talk Notes"]) {
        // guide has been published so delete it from the backend
        NSLog(@"implement object delete here");
    }
}

@end
