//
//  PhotoViewController.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 5/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotoViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
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

#pragma mark - Properties

-(void)setPhoto:(NSDictionary *)photo
{
    _photo = photo;
    [self downloadAndDisplayPhoto];
    self.title = [self getTitleForTable];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.scrollView addSubview:_imageView];
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

-(void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - UISplitViewControllerDelegate

// this method will be called when the master VC is hidden and provides us with the bar button to display as one of it arguments
-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Select Photo";
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

@end
