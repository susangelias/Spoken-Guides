//
//  fetchedResultsDataSource.m
//  Talk Lists
//
//  Created by Susan Elias on 5/14/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "fetchedResultsDataSource.h"

@implementation fetchedResultsDataSource 

#pragma mark - Fetch Results Controller

-(fetchedResultsDataSource *)initWithEntity: (NSString *)entityName
                     withManagedObjectContext:(NSManagedObjectContext *)moc
                                  withSortKey: (NSString *)sortKey
                        withCellIndentifier:(NSString *)cellID
                         withConfigureBlock:(configureCellBlock)configureBlock
{
    // Create and configure a fetch request with the  entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey
                                                                       ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // create and initialize the fetch results controller
    self = [super initWithFetchRequest:fetchRequest
                managedObjectContext:moc
                    sectionNameKeyPath:nil
                            cacheName:nil];
    self.delegate = self;
    
    self.configureCell = configureBlock;
    self.cellIdentifier = cellID;
    
    return self;
    
}


-(fetchedResultsDataSource *)init
{
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self sections] count];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [self objectAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self sections] objectAtIndex:section];
    
    // Return the number of rows in the section.
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    id item = [self itemAtIndexPath:indexPath];
    self.configureCell(cell, item);
    
    return cell;
}

@end
