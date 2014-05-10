//
//  photoAsyncHelperDelegate.h
//  
//
//  Created by Susan Elias on 5/8/14.
//
//

#import <Foundation/Foundation.h>

@protocol photoAsyncHelperDelegate <NSObject>

-(void)thumbNailRetrieved:(UIImage *)thumbNail;

@end
