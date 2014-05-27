//
//  TalkListViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/21/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "TalkListViewController.h"
#import "MyGuidesViewController.h"
#import "CatagoriesViewController.h"

@interface TalkListViewController ()

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSManagedObjectModel *mom;
@property (strong, nonatomic) NSURL *storeURL;


@end

@implementation TalkListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up managed object context
    [self setupManagedObjectContext];
    
    // Set up the undo manager
    if (self.moc) {
        self.moc.undoManager = [[NSUndoManager alloc] init];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning %s", __PRETTY_FUNCTION__);
    // Dispose of any resources that can be recreated.
}

#pragma mark navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BrowseSegue"] )
    {
        if ([[segue destinationViewController] isKindOfClass:[CatagoriesViewController class]]) {
            CatagoriesViewController *destController = [segue destinationViewController];
            destController.managedObjectContext = self.moc;
        }
    }    else if ([segue.identifier isEqualToString:@"CreateSegue"] )
    {
        if ([[segue destinationViewController] isKindOfClass:[MyGuidesViewController class]]) {
            MyGuidesViewController *destController = [segue destinationViewController];
            destController.managedObjectContext = self.moc;
        }
    }
}


#pragma mark initializers

-(void)setupManagedObjectContext
{
    self.moc =
        [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.moc.persistentStoreCoordinator =
        [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel: self.mom];
    NSError *error;
    [self.moc.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:self.storeURL
                                                            options:nil
                                                              error:&error];
    if (error) {
        NSLog(@"error:  %@", error);
    }
    self.moc.undoManager = nil;     // set to nil until such time as undo Manager is needed
}

-(NSManagedObjectModel *)mom
{
    if (!_mom) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GuideModel" withExtension:@"momd"];
        _mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _mom;
}

-(NSURL *)storeURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    if (!_storeURL) {
        _storeURL = [NSURL fileURLWithPath:[basePath stringByAppendingFormat:@"/Talk Lists.sqlite"]];
    }
    return  _storeURL;
}

@end
