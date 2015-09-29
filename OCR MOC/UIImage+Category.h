//
//  UIImage+Category.h
//  OCR MOC
//
//  Created by Paul Kovalenko on 29.09.15.
//  Copyright (c) 2015 Paul Kovalenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)

- (UIImage *) fixOrientation;

- (UIImage *) resize;

- (UIImage *) toGrayscale;

@end
