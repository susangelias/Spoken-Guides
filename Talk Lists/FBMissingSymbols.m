//
//  FBMissingSymbols.m
//  Talk Lists
//
//  Created by Susan Elias on 6/22/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

// Work around for Parse bug which looks for FB symbols when linking with -ObjC

NSString *FBTokenInformationExpirationDateKey = @"";
NSString *FBTokenInformationTokenKey = @"";
NSString *FBTokenInformationUserFBIDKey = @"";
@interface FBAppCall:NSObject
@end
@implementation FBAppCall
@end
@interface FBRequest:NSObject
@end
@implementation FBRequest
@end
@interface FBSession:NSObject
@end
@implementation FBSession
@end
@interface FBSessionTokenCaching:NSObject
@end
@implementation FBSessionTokenCaching
@end
@interface FBSessionTokenCachingStrategy:NSObject
@end
@implementation FBSessionTokenCachingStrategy
@end
