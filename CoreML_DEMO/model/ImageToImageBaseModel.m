//
//  ImageToImageModel.m
//  CoreML_DEMO
//
//  Created by dabby on 2019/7/11.
//  Copyright © 2019 Jam. All rights reserved.
//

#import "ImageToImageBaseModel.h"

@interface ImageToImageBaseModel()

@property (nonatomic, strong) NSMutableArray *requests;
@property (nonatomic, strong) ImageToImageOutputHandler outputHandler;

@end

@implementation ImageToImageBaseModel

- (void)dealloc {
    self.requests = nil;
    self.outputHandler = nil;
}

#pragma mark - public

+ (instancetype)model {
    id mo = [[self alloc] init];
    return mo;
}

- (void)inputImage:(UIImage *)inputImage withOutputHandler:(ImageToImageOutputHandler)outputHandler {
    if (self.modelURL == nil) {
        return;
    }
    if (self.requests == nil) {
        [self setup];
    }
    self.outputHandler = outputHandler;
    CGImageRef imgRef = inputImage.CGImage;
    if (imgRef) {
        imgRef = [self fixOrientation:inputImage].CGImage;
    }
    VNImageRequestHandler *reqHandler = imgRef ? [[VNImageRequestHandler alloc] initWithCGImage:imgRef options:@{}] : [[VNImageRequestHandler alloc] initWithCIImage:inputImage.CIImage options:@{}];
    [reqHandler performRequests:self.requests error:nil];
}

#pragma mark - GET

- (NSURL *)modelURL {
    return nil;
}

#pragma mark - init

- (void)setup {
    NSURL *myUrl = self.modelURL;
    id visionModel = [VNCoreMLModel modelForMLModel:[MLModel modelWithContentsOfURL:myUrl error:nil] error:nil];
    __weak id weakself = self;
    VNCoreMLRequest *objectRecognitions = [[VNCoreMLRequest alloc] initWithModel:visionModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
//        NSLog(@"request.result :%@", request.results);
        [weakself handleResults:request.results];
    }];
    self.requests = [NSMutableArray arrayWithObject:objectRecognitions];
}

#pragma mark - handle results

- (void)handleResults:(NSArray *)results {
    VNCoreMLFeatureValueObservation *firstobj = results.firstObject;
    MLMultiArray *multiArrayValue = firstobj.featureValue.multiArrayValue;
//    NSLog(@"multiArrayValue: %@", multiArrayValue);
    UIImage *newImage = [self imageWithMultiArray:multiArrayValue];
    if (self.outputHandler) {
        self.outputHandler([NSArray arrayWithObject:newImage]);
        self.outputHandler = nil;
    }
}

#pragma mark - image

- (id)imageWithMultiArray:(MLMultiArray *)multiArray {
    return nil;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
