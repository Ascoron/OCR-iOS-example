//
//  OCRAPIRequestManager.m
//  OCR MOC
//
//  Created by Paul Kovalenko on 29.09.15.
//  Copyright (c) 2015 Paul Kovalenko. All rights reserved.
//

#import "OCRAPIRequestManager.h"

#define kPostHttpStartStarted 1
#define kPostHttpStartFailedCreatingConnection -1
#define kPostHttpStartFailedConnectionInUse -2

#define API_url  @"http://api.ocrapiservice.com/1.0/rest/ocr"
#define API_key  @"X8454nxQVS"
#define LANG_key @"en"

@interface OCRAPIRequestManager ()
{
    NSURLConnection * _theConnection;
    
    NSMutableData * _receivedData;
    
    BOOL _working;
    
    NSInteger _tag;
}

@end

@implementation OCRAPIRequestManager

- (void) postImage:(UIImage *)image
{
    if (_theConnection == nil
        || _working == NO) {

        NSURL * postUrl = [NSURL URLWithString:API_url];
        NSMutableURLRequest * serviceRequest = [NSMutableURLRequest requestWithURL:postUrl
                                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                   timeoutInterval:60.0];

        NSMutableData * postData = [NSMutableData data];
        
        NSString * shortBoundary = @"---------------------------14737809831466499882746641349";
        NSString * boundary = [NSString stringWithFormat:@"--%@", shortBoundary];
        NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", shortBoundary];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        [postData appendData:[boundary dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[@"\r\nContent-Disposition: form-data; name=\"image\"; filename=\"mytest.jpg\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[@"\r\nContent-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:imageData];
        
        [postData appendData:[[NSString stringWithFormat:@"\r\n%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"\r\nContent-Disposition: form-data; name=\"language\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[LANG_key dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postData appendData:[[NSString stringWithFormat:@"\r\n%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"\r\nContent-Disposition: form-data; name=\"apikey\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[API_key dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postData appendData:[[NSString stringWithFormat:@"\r\n%@--", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [serviceRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
        [serviceRequest setHTTPMethod:@"POST"];
        [serviceRequest setHTTPBody:postData];
        
        _theConnection = [[NSURLConnection alloc] initWithRequest:serviceRequest delegate:self];
        
        if (_theConnection) {
            NSLog(@"Connection started");
            _working = YES;
            
            _receivedData = [NSMutableData data];
            
            if (self.delegate != nil) {
                [self.delegate ocrApiPostStarted:self];
            }
        }
    }
}

#pragma mark - Download events handling

- (void) connection:(NSURLConnection *)connection
 didReceiveResponse:(NSURLResponse *)response
{
    [_receivedData setLength:0];
}

- (void) connection:(NSURLConnection *)connection
     didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void) connection:(NSURLConnection *)connection
   didFailWithError:(NSError *)error
{
    _working = NO;
    
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    if (self.delegate != nil) {
        [self.delegate ocrApiPostDidFailed:self withError:error];
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %lu bytes of data", (unsigned long)[_receivedData length]);

    NSData * resultData = [[NSData alloc] initWithData:_receivedData];

    _working = NO;
    
    if (self.delegate != nil) {
        [self.delegate ocrApiPostDidFinish:self withData:resultData];
    }
}

#pragma mark - Memory handling

- (id) init {
    if ((self = [super init])) {
        // Initialization stuff
    }
    return self;
}

@end
