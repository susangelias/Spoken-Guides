//
//  Guide.h
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GuideCategory, Photo, Step;

@interface Guide : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) GuideCategory *classifiedCategory;
@property (nonatomic, retain) Photo *guidePhoto;
@property (nonatomic, retain) NSSet *stepInGuide;
@end

@interface Guide (CoreDataGeneratedAccessors)

- (void)addStepInGuideObject:(Step *)value;
- (void)removeStepInGuideObject:(Step *)value;
- (void)addStepInGuide:(NSSet *)values;
- (void)removeStepInGuide:(NSSet *)values;

@end
