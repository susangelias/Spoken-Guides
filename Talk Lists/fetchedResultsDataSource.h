//
//  fetchedResultsDataSource.h
//  Talk Lists
//
//  Created by Susan Elias on 5/14/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef void(^configureCellBlock)(UITableViewCell *, id);

@interface fetchedResultsDataSource : NSFetchedResultsController <NSFetchedResultsControllerDelegate, UITableViewDataSource>

@property (nonatomic, copy) configureCellBlock configureCell;
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSPredicate *searchPredicate;
@property (nonatomic, strong) NSArray *filteredObjects;

-(NSFetchedResultsController *)initWithEntity: (NSString *)entityName
                     withManagedObjectContext:(NSManagedObjectContext *)moc
                                  withSortKey: (NSString *)sortKey
                          withCellIndentifier: (NSString *)cellID
                          withSearchPredicate: (NSPredicate *)searchPredicate
                           withConfigureBlock: (configureCellBlock)configureBlock;

@end
