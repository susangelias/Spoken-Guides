//
//  EditGuideViewControllerDelegate.h
//  Talk Lists
//
//  Created by Susan Elias on 7/15/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFGuide.h"
#import "PFStep.h"

@protocol EditGuideViewControllerDelegate <NSObject>

@optional

//-(void)guideWasChanged:(PFGuide *)guideObject guideImage: (UIImage *)changedImage guideThumbnail: (UIImage *)changedThumbnail;
-(void) changedGuideUploading;
-(void) changedGuideFinishedUpload;
-(void) changedStepUploading;
-(void) changedStepFinishedUpload;
//-(void)stepWasChanged:(PFStep *)guideObject stepImage: (UIImage *)changedImage stepThumbnail: (UIImage *)changedThumbnail;

@end
