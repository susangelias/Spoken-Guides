//
//  parseDataSource.m
//  Talk Lists
//
//  Created by Susan Elias on 6/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//


#import "parseDataSource.h"

@implementation parseDataSource

-(parseDataSource *)initWithPFObjectClassName:(NSString *)PFObjectClassName
                                  withSortKey:(NSString *)sortKey
                                withMatchKey:(NSString *)matchKey
                              WithMatchString:(NSString *)matchString
                          withCellIndentifier:(NSString *)cellID
                           configureCellBlock:(id)configCellBlock
{
    self = [super init];
    if (self) {
        // create and configure a PFQuery on the given class name
        self.query = [PFQuery queryWithClassName:PFObjectClassName];
        
         // Follow relationship
        [self.query whereKey:matchKey equalTo:matchString];
        
        [self.query orderByAscending:sortKey];
        
        self.query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        
        /*
        __weak typeof(self) weakSelf = self;
        [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                weakSelf.queryResults = [objects copy];
                [weakSelf.parseDataSourceDelegate queryComplete];
            }
        }];
         */
      //  [self refreshQuery];

        self.cellIdentifier = cellID;
        self.configureCell = configCellBlock;
    }
    return self;
}

-(void)refreshQuery
{
    __weak typeof(self) weakSelf = self;
    [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            weakSelf.queryResults = [objects copy];
            [weakSelf.parseDataSourceDelegate queryComplete];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.queryResults[(NSUInteger) indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // This data source class only supports 1 section
    NSParameterAssert(section == 0);
    
    // Return the number of rows in the section.
    return [self.queryResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    id item = [self.queryResults objectAtIndex:indexPath.row];
    self.configureCell(cell, item);
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return self.editingAllowed;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.parseDataSourceDelegate deletedRowAtIndex:indexPath.row];       // let the view controller know a row will be deleted
        [self.queryResults removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.parseDataSourceDelegate movedRowFrom:fromIndexPath.row To:toIndexPath.row];  // let the view controller know a row is moving
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return self.rearrangingAllowed;
}


@end
