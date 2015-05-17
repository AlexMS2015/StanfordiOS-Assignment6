//
//  Photo+LoadIntoFlickr.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 10/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "Photo+LoadIntoFlickr.h"
#import "FlickrFetcher.h"
#import "Region+LoadIntoFlickr.h"
#import "Photographer.h"
#import "Photographer+LoadIntoFlickr.h"
#import "FlickrDownloadSession.h"

@implementation Photo (LoadIntoFlickr)

-(void)addRegionFromPlaceID:(NSString *)placeID
                  inContext:(NSManagedObjectContext *)context
{
    NSURL *placeURL = [FlickrFetcher URLforInformationAboutPlace:placeID];
    NSURLRequest *placeURLRequest = [NSURLRequest requestWithURL:placeURL];
    
    NSURLSessionDownloadTask *downloadPlaceInfo = [[FlickrDownloadSession sharedFlickrDownloadSession] downloadTaskWithRequest:placeURLRequest
                                                                 completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {

            // load local file contents into NSData
            NSData *JSONData = [NSData dataWithContentsOfURL:location];
            NSDictionary *placeInformation = [NSJSONSerialization JSONObjectWithData:JSONData
                                                                          options:0
                                                                            error:NULL];
            NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:placeInformation];

            self.region = [Region regionWithName:regionName
                              addPhotographer:self.photographer
                                    inContext:context];
            }];
    
    [downloadPlaceInfo resume];
}

+(void)photoFromFlickrPhoto:(NSDictionary *)photo inContext:(NSManagedObjectContext *)context
{
    
    Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                    inManagedObjectContext:context];
    
    newPhoto.photoDescription = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    newPhoto.photoTitle = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    NSURL *photoUrl = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    NSURL *thumbnailUrl = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatSquare];
    newPhoto.photoURL = [photoUrl absoluteString];
    newPhoto.thumbnailURL = [thumbnailUrl absoluteString];
    Photographer *photographer = [Photographer photographerWithName:[photo valueForKeyPath:FLICKR_PHOTO_OWNER] inContext:context];
    newPhoto.photographer = photographer;
    
    [newPhoto addRegionFromPlaceID:[photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID] inContext:context];
}

+(void)loadPhotosFromFlickrArray:(NSArray *)photos intoContext:(NSManagedObjectContext *)context
{
    NSLog(@"there are %d photos to load", [photos count]);
    [photos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx < 100) {
            NSLog(@"-------------");
            NSLog(@"loading photo %d", idx);
            [Photo photoFromFlickrPhoto:obj inContext:context];
        }
    }];
}

@end
