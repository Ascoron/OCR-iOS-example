//
//  ViewController.m
//  OCR MOC
//
//  Created by Paul Kovalenko on 28.09.15.
//  Copyright (c) 2015 Paul Kovalenko. All rights reserved.
//

#import "ViewController.h"

#import "UIImage+Category.h"

#import <TesseractOCR/TesseractOCR.h>

#import "OCRAPIRequestManager.h"

@interface ViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate,
G8TesseractDelegate, OcrApiManagerDelegate>
{
    __weak IBOutlet UIActivityIndicatorView * _activityIndicatorView;
    
    BOOL _needUpload;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _activityIndicatorView.hidden = YES;
}

#pragma mark - actions

- (IBAction) takeImageAction:(id)sender
{
    _needUpload = NO;
    
    [self showPickerWithType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction) selectImage:(id)sender
{
    _needUpload = NO;
    
    [self showPickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction) takeImageToAPIAction:(id)sender
{
    _needUpload = YES;
    
    [self showPickerWithType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction) selectToAPIImage:(id)sender
{
    _needUpload = YES;
    
    [self showPickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void) showPickerWithType:(UIImagePickerControllerSourceType)type
{
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    if (imagePicker && [UIImagePickerController isSourceTypeAvailable:type]) {
        imagePicker.sourceType = type;
        
        [self presentViewController:imagePicker animated:YES completion:^{
        }];
    }
}

#pragma mark - recognize image

- (void) ocrApiPostStarted:(id) sender
{
    NSLog(@"Post started");
}

- (void) ocrApiPostDidFailed:(id) sender
                   withError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"There was an error while processing the image or posting to the service"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
    NSLog(@"Post failed");
}

- (void) ocrApiPostDidFinish:(id) sender
                    withData:(NSData *)data
{
    [self displayResult:[[NSString alloc] initWithData:data
                                              encoding:NSASCIIStringEncoding]];
}

- (void) displayResult:(NSString *) result
{
    [_activityIndicatorView stopAnimating];
    _activityIndicatorView.hidden = YES;
    
    [[[UIAlertView alloc] initWithTitle:@"OCR Result"
                                message:result
                               delegate:nil
                      cancelButtonTitle:@"OK"
                        otherButtonTitles:nil] show];
}


- (void) apiRecognizeImage:(UIImage *)image
{
    OCRAPIRequestManager * manager = [OCRAPIRequestManager new];
    
    manager.delegate = self;
    
    [manager postImage:image];
}

- (void) recognizeImage:(UIImage *)image
{
    //for best results need crop image
    
//    UIImage * tmp = [image resize];
    
    UIImage * bwImage = [image toGrayscale]; // OR [tmp2 g8_blackAndWhite]

    G8RecognitionOperation * operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
    
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeSingleBlock;

    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    
    operation.delegate = self;
    
    operation.tesseract.charWhitelist = @"0123456789 QWERTYUIOPLKJHGFDSAZXCVBNMmnbvcxzasdfghjklpoiuytrewq";
    
    operation.tesseract.image = bwImage;
    
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        NSLog(@"%@",tesseract.recognizedText);
        [self displayResult:tesseract.recognizedText];
    };
    
    NSOperationQueue * opQ = [NSOperationQueue new];
    
    [opQ addOperation:operation];
    
}

#pragma mark - UIImagePickerController delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * newImage = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [_activityIndicatorView startAnimating];
        _activityIndicatorView.hidden = NO;

        if (!_needUpload) {
            [self recognizeImage:newImage];
        }
        else {
            [self apiRecognizeImage:newImage];
        }
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
