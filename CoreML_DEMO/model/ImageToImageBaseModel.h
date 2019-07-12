//
//  ImageToImageModel.h
//  CoreML_DEMO
//
//  Created by dabby on 2019/7/11.
//  Copyright © 2019 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Vision/Vision.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ImageToImageOutputHandler)(NSArray *outputImages);

@interface ImageToImageBaseModel : NSObject

@property (nonatomic, readonly) NSURL *modelURL;

+ (instancetype)model;
- (void)inputImage:(UIImage *)inputImage withOutputHandler:(ImageToImageOutputHandler)outputHandler;
- (id)imageWithMultiArray:(MLMultiArray *)multiArray;

@end

NS_ASSUME_NONNULL_END
