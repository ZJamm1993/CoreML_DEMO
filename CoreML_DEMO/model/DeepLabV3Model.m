//
//  DeepLabV3Model.m
//  CoreML_DEMO
//
//  Created by dabby on 2019/7/11.
//  Copyright © 2019 Jam. All rights reserved.
//

#import "DeepLabV3Model.h"

@implementation DeepLabV3Model

- (NSURL *)modelURL {
    return [[NSBundle mainBundle] URLForResource:@"DeepLabV3Int8LUT" withExtension:@"mlmodelc"];
}

- (id)imageWithMultiArray:(MLMultiArray *)multiArray {
    NSArray *shape = multiArray.shape;
    
    size_t width = [shape[0] integerValue];
    size_t height = [shape[1] integerValue];
    size_t bitsPerComponent = 8;
    NSInteger depth = 3;
    size_t bitsPerPixel = bitsPerComponent * depth;
    size_t bytesPerRow = width * bitsPerPixel / 8;
    
    void *dataPointer = multiArray.dataPointer;
    NSInteger dataCount = multiArray.count;
    uint32_t *data32Arr = dataPointer; // model says it will bit Int32
    
    NSInteger outputLength = dataCount * depth;
    uint8_t outputArr[outputLength];
    memset(outputArr, 0, outputLength);
    
    double maxvalue = 0;
    for (NSInteger i = 0; i < dataCount; i++) {
        uint32_t this = data32Arr[i];
        if (this > maxvalue) {
            maxvalue = this;
        }
    }
    CGFloat r_float = 0;
    CGFloat g_float = 0;
    CGFloat b_float = 0;
    CGFloat a_float = 0;
    for (NSInteger i = 0; i < dataCount; i++) {
        double this = (double)(data32Arr[i]);
        //        printf("%f, ", this);
        this = this / maxvalue;
        // turn Grayscale into Hue
        UIColor *hsv = [UIColor colorWithHue:this * 0.7 saturation:1 brightness:this == 0 ? 0 : 1 alpha:1];
        [hsv getRed:&r_float green:&g_float blue:&b_float alpha:&a_float];
        uint8_t r_value = r_float * 255;
        uint8_t g_value = g_float * 255;
        uint8_t b_value = b_float * 255;
        outputArr[i * depth + 0] = r_value;
        outputArr[i * depth + 1] = g_value;
        outputArr[i * depth + 2] = b_value;
    }
    
    CFDataRef dataRef = CFDataCreate(NULL, outputArr, outputLength);
    CGDataProviderRef dataProviderRef = CGDataProviderCreateWithCFData(dataRef);
    
    CGImageRef ref = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault, dataProviderRef, NULL, false, kCGRenderingIntentDefault);
    UIImage *newImage = [UIImage imageWithCGImage:ref];
    
    CGImageRelease(ref);
    CFRelease(dataProviderRef);
    CFRelease(dataRef);
    return newImage;
}

@end
