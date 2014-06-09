//
//  Photo+Addendums.m
//  Talk Lists
//
//  Created by Susan Elias on 5/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Photo+Addendums.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation Photo (Addendums)

+(NSString *)entityName
{
    return @"Photo";
}

+(instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:moc];
}

-(void)retrieveImageWithCompletionBlock:(ASCompletionBlock) callback
{
    // retrieves the photo from the phone's library asynchronously and stores it into core data
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library getImageForAssetURL:[NSURL URLWithString:self.assetLibraryURL]
             withCompletionBlock:^(UIImage *image, NSError *error) {
                 BOOL success = NO;
                 NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
                 if (!error) {
                     success = YES;
                     [response setObject:image forKey:@"photoImage"];
                 }
                 if (callback) {
                     callback(success, [response copy], error);
                 }
             }];
}

-(void)retreiveThumbNailWithCompletionBlock:(ASCompletionBlock)completionBlock
{
    
}

@end
