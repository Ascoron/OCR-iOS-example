//
//  OCRAPIRequestManager.h
//  OCR MOC
//
//  Created by Paul Kovalenko on 29.09.15.
//  Copyright (c) 2015 Paul Kovalenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol OCRAPIRequestManagerDelegate <NSObject>
@optional
- (void) ocrApiPostStarted:(id) sender;
- (void) ocrApiPostDidFailed:(id) sender
                   withError:(NSError *)error;
- (void) ocrApiPostDidFinish:(id) sender
                    withData:(NSData *)data;
@end

@interface OCRAPIRequestManager : NSObject

@property (nonatomic, retain) id <OCRAPIRequestManagerDelegate> delegate;

- (void) postImage:(UIImage *)image;

@end
