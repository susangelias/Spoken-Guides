//
//  UIImage+Resize.m
//  Talk Lists
//
//  Created by Susan Elias on 5/8/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

-(UIImage *)resizeToSquareImage:(UIImage *)originalPhoto
{
    UIImage *resizedImage;
    CGImageRef coreGraphicsImage = originalPhoto.CGImage;
    CGFloat height = CGImageGetHeight(coreGraphicsImage);
    CGFloat width = CGImageGetWidth(coreGraphicsImage);
    CGRect crop;
    // Want to use square images instead of rectangle, so crop to do this
    if (height > width) {
        crop.size.height = crop.size.width = width;
        crop.origin.x = 0;
        crop.origin.y = floorf((height- width)/2);
    }
    else {
        crop.size.height = crop.size.width = height;
        crop.origin.y = 0;
        crop.origin.x = floorf((width-height)/2);
    }
    CGImageRef croppedImage = CGImageCreateWithImageInRect(coreGraphicsImage, crop);
    
    // scale down image to smaller size and make sure it is oriented the way the picture was taken
    resizedImage = [UIImage imageWithCGImage:croppedImage
                                       scale:MAX(crop.size.height/512, 1.0)
                                 orientation:originalPhoto.imageOrientation];
    
    // release core graphics images as ARC does not do this for us
    CGImageRelease(croppedImage);
    
    return resizedImage;
    
}

@end
