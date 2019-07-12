//
//  PhotoViewController.m
//  Vision-demo
//
//  Created by dabby on 2019/6/18.
//  Copyright © 2019 Jam. All rights reserved.
//

#import "PhotoViewController.h"
#import "ImageToImageBaseModel.h"
#import "DeepLabV3Model.h"
#import "FCRNModel.h"

@interface PhotoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *inputImageView;
@property (weak, nonatomic) IBOutlet UIImageView *outputImageView;
@property (nonatomic, strong) ImageToImageBaseModel *model;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.model = [DeepLabV3Model model];
    [self selectPhoto:nil];
}

- (IBAction)selectPhoto:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectFromCamera:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectFromCamera:NO];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)selectFromCamera:(BOOL)fromCamara {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = fromCamara ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    //    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didSelectedPhoto:(UIImage *)image {
    self.inputImageView.image = image;
    [self.model inputImage:image withOutputHandler:^(NSArray * _Nonnull outputImages) {
        self.outputImageView.image = outputImages.firstObject;
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self didSelectedPhoto:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
