//
//  PhotoViewController.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 5/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation PhotoViewController

#pragma mark - Helpers / Other

-(NSString *)getTitleForTable
{
    if (![[self.photo valueForKeyPath:FLICKR_PHOTO_TITLE] isEqualToString:@""]) {
        return [self.photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    } else if (![[self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] isEqualToString:@""]) {
        return [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    } else {
        return @"Unknown";
    }
}

-(void)downloadAndDisplayPhoto
{
    NSURL *photoUrl = [FlickrFetcher URLforPhoto:self.photo format:FlickrPhotoFormatLarge];
    NSURLRequest *photoRequest = [NSURLRequest requestWithURL:photoUrl];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDownloadTask *downloadPhotoTask = [session downloadTaskWithRequest:photoRequest
                                                                 completionHandler:
           ^(NSURL *location, NSURLResponse *response, NSError *error) {
               NSData *imageData = [NSData dataWithContentsOfURL:location];
               UIImage *image = [UIImage imageWithData:imageData];
               dispatch_async(dispatch_get_main_queue(), ^{
                   self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                   self.imageView.image = image;
                   self.scrollView.contentSize = self.imageView.bounds.size;
               });
           }];
    [downloadPhotoTask resume];
}

-(void)scaleImageInScrollView
{
    
}

#pragma mark - Properties

-(NSDictionary *)photo
{
    if (!_photo) {
        _photo = [NSDictionary dictionary];
    }
    
    return _photo;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

-(void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
}

#pragma mark - Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [self getTitleForTable];
    [self.scrollView addSubview:self.imageView];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self downloadAndDisplayPhoto];
    [self scaleImageInScrollView];
}

#pragma mark - UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
