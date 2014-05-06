//
//  GuideCategory.h
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GuideCategory : NSManagedObject

@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSSet *memberGuide;
@end

@interface GuideCategory (CoreDataGeneratedAccessors)

- (void)addMemberGuideObject:(NSManagedObject *)value;
- (void)removeMemberGuideObject:(NSManagedObject *)value;
- (void)addMemberGuide:(NSSet *)values;
- (void)removeMemberGuide:(NSSet *)values;

@end
